# frozen_string_literal: true

# импорт данных из файла .json
class ImportData < ActiveInteraction::Base
  string :file_name

  def execute
    ActiveRecord::Base.transaction do
      delete_data
      import_data
    end
  end

  private

  def delete_data
    City.delete_all
    Bus.delete_all
    Service.delete_all
    Trip.delete_all
    BusesService.delete_all
  end

  def import_data
    @trips = []
    @buses = {}
    @services = {}
    @cities = {}

    Oj.load_file(file_name).each do |trip|
      @trips << trip_new(trip)
    end

    Service.import(@services.values)
    Bus.import(@buses.values, recursive: true)
    City.import(@cities.values)
    Trip.import(@trips)
  end

  def trip_new(trip)
    Trip.new(
      from: take_city(trip['from']),
      to: take_city(trip['to']),
      bus: take_bus(trip['bus']),
      start_time: trip['start_time'],
      duration_minutes: trip['duration_minutes'],
      price_cents: trip['price_cents']
    )
  end

  def take_city(name)
    @cities[name] ||= City.new(name: name)
  end

  def take_bus(bus)
    @buses[bus['number']] ||= Bus.new(
      number: bus['number'],
      model: bus['model'],
      services: take_bus_services(bus)
    )
  end

  def take_bus_services(bus)
    bus['services'].map do |service|
      @services[service] ||= Service.new(name: service)
    end
  end
end
