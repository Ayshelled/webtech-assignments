require "test_helper"

class ListingPolicyTest < ActiveSupport::TestCase
  setup do
    @host      = create_member("host")
    @other     = create_member("other")
    @moderator = create_member("moderator", role: :moderator)
    @draft     = create_listing(@host, status: :draft)
    @published = create_listing(@host)
  end

  test "a draft is seen only by its host and by moderators" do
    assert ListingPolicy.new(@host, @draft).show?
    assert ListingPolicy.new(@moderator, @draft).show?
    assert_not ListingPolicy.new(@other, @draft).show?
    assert_not ListingPolicy.new(nil, @draft).show?
    assert ListingPolicy.new(nil, @published).show?
  end

  test "the host or a moderator edits and deletes; only the host publishes" do
    assert ListingPolicy.new(@host, @published).update?
    assert ListingPolicy.new(@moderator, @published).destroy?
    assert_not ListingPolicy.new(@other, @published).update?
    assert_not ListingPolicy.new(@moderator, @draft).publish?
    assert ListingPolicy.new(@host, @draft).publish?
  end

  test "the scope hides other people's drafts" do
    assert_not_includes ListingPolicy::Scope.new(@other, Listing).resolve, @draft
    assert_not_includes ListingPolicy::Scope.new(nil, Listing).resolve, @draft
    assert_includes ListingPolicy::Scope.new(@host, Listing).resolve, @draft
    assert_includes ListingPolicy::Scope.new(@moderator, Listing).resolve, @draft
  end

  test "catalogs and reports belong to moderators" do
    assert NeighborhoodPolicy.new(@moderator, Neighborhood).create?
    assert_not NeighborhoodPolicy.new(@host, Neighborhood).create?
    assert ReportPolicy.new(@moderator, Report).resolve?
    assert_not ReportPolicy.new(@host, Report).resolve?
    assert ReportPolicy.new(@other, Report.new(listing: @published)).create?
    assert_not ReportPolicy.new(@host, Report.new(listing: @published)).create?
  end
end
