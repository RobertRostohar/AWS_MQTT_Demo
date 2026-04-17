# -----------------------------------------------------------------------------
# Copyright (c) 2026 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the License); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an AS IS BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# -----------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.16)

# Configure AWS IoT Thing by updating #define placeholders in the config file
# with values from the following environment variables:
#   IOT_THING_NAME           - AWS IoT Thing name
#   MQTT_BROKER_ENDPOINT     - AWS IoT MQTT broker endpoint
#   ROOT_CA_PEM              - Root CA certificate (PEM format)
#   CLIENT_CERTIFICATE_PEM   - Client certificate (PEM format)
#   CLIENT_PRIVATE_KEY_PEM   - Client private key (PEM format)
#
# Usage:
#   cmake -DINPUT_FILE=<input-file> -DOUTPUT_FILE=<output-file> -P configure-thing.cmake

set(_input_file "")
set(_output_file "")

if(DEFINED INPUT_FILE AND NOT INPUT_FILE STREQUAL "")
    set(_input_file "${INPUT_FILE}")
endif()

if(DEFINED OUTPUT_FILE AND NOT OUTPUT_FILE STREQUAL "")
    set(_output_file "${OUTPUT_FILE}")
endif()

if(_input_file STREQUAL "" OR _output_file STREQUAL "")
    message(FATAL_ERROR
        "Missing file path arguments!\n"
        "Usage: cmake -DINPUT_FILE=<input-file> -DOUTPUT_FILE=<output-file> -P configure-thing.cmake")
endif()

get_filename_component(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)

set(INPUT_FILE_PATH "${_input_file}")
if(NOT IS_ABSOLUTE "${INPUT_FILE_PATH}")
    get_filename_component(INPUT_FILE_PATH "${INPUT_FILE_PATH}" ABSOLUTE BASE_DIR "${PROJECT_ROOT}")
endif()

set(OUTPUT_FILE_PATH "${_output_file}")
if(NOT IS_ABSOLUTE "${OUTPUT_FILE_PATH}")
    get_filename_component(OUTPUT_FILE_PATH "${OUTPUT_FILE_PATH}" ABSOLUTE BASE_DIR "${PROJECT_ROOT}")
endif()

if(NOT EXISTS "${INPUT_FILE_PATH}")
    message(FATAL_ERROR "Input file does not exist: ${INPUT_FILE_PATH}")
endif()

if(IS_DIRECTORY "${INPUT_FILE_PATH}")
    message(FATAL_ERROR "Input path is not a file: ${INPUT_FILE_PATH}")
endif()

get_filename_component(OUTPUT_FILE_DIR "${OUTPUT_FILE_PATH}" DIRECTORY)
if(NOT EXISTS "${OUTPUT_FILE_DIR}")
    file(MAKE_DIRECTORY "${OUTPUT_FILE_DIR}")
endif()

function(get_env_variable name out_var)
    if(NOT DEFINED ENV{${name}} OR "$ENV{${name}}" STREQUAL "")
        message(FATAL_ERROR "Missing required environment variable: ${name}")
    endif()
    set(${out_var} "$ENV{${name}}" PARENT_SCOPE)
endfunction()

function(escape_c_string value out_var)
    set(_escaped "${value}")
    string(REPLACE "\\" "\\\\" _escaped "${_escaped}")
    string(REPLACE "\"" "\\\"" _escaped "${_escaped}")
    string(REPLACE "\n" "\\n" _escaped "${_escaped}")
    set(${out_var} "\"${_escaped}\"" PARENT_SCOPE)
endfunction()

function(format_str value out_var)
    escape_c_string("${value}" _formatted)
    set(${out_var} "${_formatted}" PARENT_SCOPE)
endfunction()

function(format_pem value out_var)
    set(_normalized "${value}")
    string(REPLACE "\\n" "\n" _normalized "${_normalized}")
    string(REPLACE "\r\n" "\n" _normalized "${_normalized}")
    string(REPLACE "\r" "\n" _normalized "${_normalized}")
    if(NOT _normalized MATCHES "\n$")
        string(APPEND _normalized "\n")
    endif()
    escape_c_string("${_normalized}" _formatted)
    set(${out_var} "${_formatted}" PARENT_SCOPE)
endfunction()

function(set_define content_var name value)
    set(_content "${${content_var}}")

    string(REGEX MATCH "[ \t]*\\* #define ${name}[^\n]*\r?\n[ \t]*\\*/" _placeholder "${_content}")

    if(_placeholder STREQUAL "")
        message(FATAL_ERROR "Unable to locate placeholder for ${name} in ${INPUT_FILE_PATH}.")
    endif()

    string(REPLACE "${_placeholder}" " */\n#define ${name} ${value}" _updated "${_content}")
    set(${content_var} "${_updated}" PARENT_SCOPE)
endfunction()

message(STATUS "AWS IoT Thing configuration based on environment variables...")

get_env_variable("IOT_THING_NAME" IOT_THING_NAME)
get_env_variable("MQTT_BROKER_ENDPOINT" MQTT_BROKER_ENDPOINT)
get_env_variable("ROOT_CA_PEM" ROOT_CA_PEM)
get_env_variable("CLIENT_CERTIFICATE_PEM" CLIENT_CERTIFICATE_PEM)
get_env_variable("CLIENT_PRIVATE_KEY_PEM" CLIENT_PRIVATE_KEY_PEM)

format_str("${IOT_THING_NAME}" DEF_CLIENT_IDENTIFIER)
format_str("${MQTT_BROKER_ENDPOINT}" DEF_MQTT_BROKER_ENDPOINT)
format_pem("${ROOT_CA_PEM}" DEF_ROOT_CA_PEM)
format_pem("${CLIENT_CERTIFICATE_PEM}" DEF_CLIENT_CERTIFICATE_PEM)
format_pem("${CLIENT_PRIVATE_KEY_PEM}" DEF_CLIENT_PRIVATE_KEY_PEM)

file(READ "${INPUT_FILE_PATH}" CONTENT)

set_define(CONTENT "democonfigCLIENT_IDENTIFIER" "${DEF_CLIENT_IDENTIFIER}")
set_define(CONTENT "democonfigMQTT_BROKER_ENDPOINT" "${DEF_MQTT_BROKER_ENDPOINT}")
set_define(CONTENT "democonfigROOT_CA_PEM" "${DEF_ROOT_CA_PEM}")
set_define(CONTENT "democonfigCLIENT_CERTIFICATE_PEM" "${DEF_CLIENT_CERTIFICATE_PEM}")
set_define(CONTENT "democonfigCLIENT_PRIVATE_KEY_PEM" "${DEF_CLIENT_PRIVATE_KEY_PEM}")

file(WRITE "${OUTPUT_FILE_PATH}" "${CONTENT}")

message(STATUS "Input:  ${INPUT_FILE_PATH}")
message(STATUS "Output: ${OUTPUT_FILE_PATH}")
