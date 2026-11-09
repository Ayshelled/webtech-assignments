require "test_helper"

# The permission table of Assignment 4 for applications, and the scope that
# builds the host's inbox and the seeker's list
class ApplicationPolicyTest < ActiveSupport::TestCase
  setup do
    @host      = create_member("host")
    @seeker    = create_member("seeker")
    @stranger  = create_member("stranger")
    @moderator = create_member("moderator", role: :moderator)
    @application = create_application(create_listing(@host), @seeker)
  end

  test "the seeker, the host and a moderator see an application; nobody else" do
    assert ApplicationPolicy.new(@seeker, @application).show?
    assert ApplicationPolicy.new(@host, @application).show?
    assert ApplicationPolicy.new(@moderator, @application).show?
    assert_not ApplicationPolicy.new(@stranger, @application).show?
    assert_not ApplicationPolicy.new(nil, @application).show?
  end

  test "only the host answers, not even a moderator" do
    assert ApplicationPolicy.new(@host, @application).accept?
    assert_not ApplicationPolicy.new(@moderator, @application).accept?
    assert_not ApplicationPolicy.new(@seeker, @application).shortlist?
  end

  test "a member can't apply to their own listing" do
    assert_not ApplicationPolicy.new(@host, Application.new(listing: @application.listing)).create?
    assert ApplicationPolicy.new(@stranger, Application.new(listing: @application.listing)).create?
    assert_not ApplicationPolicy.new(nil, Application.new(listing: @application.listing)).create?
  end

  test "the scope returns only what each user may see" do
    assert_includes ApplicationPolicy::Scope.new(@seeker, Application).resolve, @application
    assert_includes ApplicationPolicy::Scope.new(@host, Application).resolve, @application
    assert_includes ApplicationPolicy::Scope.new(@moderator, Application).resolve, @application
    assert_empty ApplicationPolicy::Scope.new(@stranger, Application).resolve
    assert_empty ApplicationPolicy::Scope.new(nil, Application).resolve
  end
end
