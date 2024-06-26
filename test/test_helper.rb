ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "pry"
Dir[Rails.root.join('test/support/**/*.rb')].sort.each { |file| require file }

class Capybara::Node::Element
  def obsolete?
    inspect.include?('Obsolete')
  end

  def exists?
    !obsolete?
  end
end

class ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers

  Capybara.default_max_wait_time = 8

  def login_as(user_or_person)
    user = if user_or_person.is_a?(Person)
      user_or_person.user
    else
      user_or_person
    end
    post login_path, params: { email: user.person.email, password: "secret" }
    assert_response :redirect
    follow_redirect!
    follow_redirect!
    assert_response :success
  end

  def assert_logged_in(user = nil)
    if user.nil?
      assert session.fetch(:current_user_id)
    else
      assert_equal session[:current_user_id], user.id
    end
  end
end

module ActiveSupport
  class TestCase
    include Turbo::Broadcastable::TestHelper
    include ActiveJob::TestHelper
    include FeatureHelpers
    include PostgresqlHelper
    include ViewHelpers

    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end
