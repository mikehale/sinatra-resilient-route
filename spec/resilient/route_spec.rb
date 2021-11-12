require "rack/test"
require "sinatra/base"
require "sinatra/namespace"
require "sinatra/resilient/route"

describe "Sinatra::Resilient::Route" do
  include Rack::Test::Methods

  class Collector
    def self.last_route=(last_route)
      @last_route = last_route
    end

    def self.last_route
      @last_route
    end

    def self.reset
      @last_route = nil
    end
  end

  def app
    Sinatra.new do
      register Sinatra::Resilient::Route
      register Sinatra::Namespace
      set :show_exceptions, false
      set :raise_errors, true

      after do
        Collector.last_route = env["sinatra.route"]
      end

      get "/foo/:id" do
        200
      end

      namespace "/before-error" do
        before do
          raise "from before"
        end

        get "/:id" do
          200
        end
      end

      namespace "/foobar" do
        get "/:id" do
          200
        end
      end
    end
  end

  before do
    Collector.reset
  end

  it "creates the correct route" do
    get "/foo/43"
    expect(Collector.last_route).to eq "GET /foo/:id"
  end

  it "creates the correct route for a namespace" do
    get "/foobar/43"
    expect(Collector.last_route).to eq "GET /foobar/:id"
  end

  it "creates the correct route when an error is raised" do
    expect { get "/before-error/43" }.to raise_error(/from before/)
    expect(Collector.last_route).to eq "GET /before-error/:id"
  end
end
