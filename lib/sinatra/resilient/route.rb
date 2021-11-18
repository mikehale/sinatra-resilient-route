# frozen_string_literal: true

require_relative "route/version"
require "sinatra/base"

module Sinatra
  module Resilient
    module Route
      class Error < StandardError; end

      module Helpers
        def ensure_sinatra_route
          unless env["sinatra.resilient.route"]
            Array(settings.routes[@request.request_method]).each do |pattern, conditions, _|
              break if process_route(pattern, conditions) { :found_route } == :found_route
            end
          end

          env["sinatra.route"] = env["sinatra.resilient.route"]
        end
      end

      Sinatra1StyleRenderer = ::Mustermann::AST::Translator.create do
        translate(:named_splat)      { "{+#{name}}"                           }
        translate(:splat)            { "*"                                    }
        translate(:char, :separator) { ::Mustermann::Sinatra.escape(payload)  }
        translate(:root)             { t(payload)                             }
        translate(:group)            { "(#{t(payload)})"                      }
        translate(:union)            { "(#{t(payload, join: "|")})" }
        translate(:optional)         { "#{t(payload)}?"                       }
        translate(Array)             { |join: ""| map { |e| t(e) }.join(join) }

        translate(:capture) do
          raise Mustermann::Error, "cannot render variables"      if node.is_a? :variable
          raise Mustermann::Error, "cannot translate constraints" if constraint || qualifier || convert

          ":#{name}"
        end
      end

      def self.registered(app)
        app.helpers Helpers

        app.before do
          ensure_sinatra_route
        end

        app.after do
          ensure_sinatra_route
        end
      end

      def route(verb, path, *)
        path = Mustermann.new(path) if path.is_a?(String)
        munged_path = Sinatra1StyleRenderer.translate(path.to_ast).to_s

        condition do
          env["sinatra.resilient.route"] = "#{verb} #{munged_path}"
          true
        end

        super
      end
    end
  end

  register Resilient::Route
end
