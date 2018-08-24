# frozen_string_literal: true

require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Run Standard JS'
task :standardjs do
  sh %(cd #{Rails.root} && yarn lint)
end

namespace :standardjs do
  desc 'Auto-correct Standard JS offenses'
  task :auto_correct do
    sh %(cd #{Rails.root} && yarn lint --fix)
  end
end

desc 'Run linters'
task lint: %i[rubocop standardjs]

namespace :lint do
  desc 'Auto-correct linter offenses'
  task auto_correct: %i[rubocop:auto_correct standardjs:auto_correct]
end

task default: :lint
