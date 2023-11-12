# frozen_string_literal: true

namespace :profile do
  task memory: :environment do
    report = MemoryProfiler.report { import_data }
    report.pretty_print(scale_bytes: true)
  end

  task wall_time: :environment do
    GC.disable
    RubyProf.measure_mode = RubyProf::WALL_TIME

    result = RubyProf.profile { import_data }

    printer = RubyProf::FlatPrinter.new(result)
    printer.print(File.open("log/ruby_prof_reports/flat_#{Time.current.to_formatted_s(:number)}.txt", 'w+'))

    printer = RubyProf::GraphHtmlPrinter.new(result)
    printer.print(File.open("log/ruby_prof_reports/graph_#{Time.current.to_formatted_s(:number)}.html", 'w+'))

    GC.enable
  end

  task benchmark: :environment do
    time = Benchmark.realtime { import_data }
    puts time.round(2)
    puts format('MEMORY USAGE: %d MB', `ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end

  # example small medium large
  def import_data
    ImportData.run!(file_name: 'fixtures/small.json')
  end
end
