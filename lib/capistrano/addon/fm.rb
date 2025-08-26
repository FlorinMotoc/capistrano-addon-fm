# frozen_string_literal: true

require_relative "fm/version"

load File.expand_path("fm/stages/fm-addon-stage.rb", __dir__)
# set :stage, :'fm-addon-stage' unless fetch(:stage, nil)

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

namespace 'fm' do
  task 'readme' do
    run_locally do
      gem_root = File.expand_path('../../../', __dir__)
      Dir.chdir(gem_root) do
        system('cat readme.md')
      end
    end
  end
  task 'readme:tasks' do
    run_locally do
      gem_root = File.expand_path('../../../', __dir__)
      Dir.chdir(gem_root) do
        system("awk '
  /^## Usage$/ { print; in_section=1; next }
  /^## Configuration$/ { exit }
  in_section { print }
' README.md
")
      end
    end
  end
end
