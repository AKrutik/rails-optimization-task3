# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

describe 'utils.rake' do
  it 'import large.json' do
    expect { Rake::Task['reload_json'].invoke('fixtures/large.json') }.to perform_under(60).sec.warmup(2).times.sample(10).times
  end
end