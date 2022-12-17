#!/bin/bash

swift-format --configuration swift-format-config.json -i -r Sources
swift-format --configuration swift-format-config.json -i -r Examples

