# frozen_string_literal: true

require_relative "fm/version"

# Load all .rake files from the tasks directory
Dir.glob(File.expand_path("./fm/tasks/**/*.rake", __dir__)).each { |r| load r }

module Capistrano
  module Addon
    module Fm
      class Error < StandardError; end
      # Your code goes here...
    end
  end
end
