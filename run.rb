#!/bin/env ruby

require 'sita'

xml = ARGV[0] || "test.xml"

function = Sita::Function.new( File.new( xml ) )

Sita::Tests::SQL_Injection.new( function ).run

