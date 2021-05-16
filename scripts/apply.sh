#!/bin/sh

terrafrom init -input=false -no-color
terrafrom apply -input=false -no-color -auto-approve