require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: 'foobarbazz', password_confirmation: 'foobarbazz')
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "name should not be more than 50 char" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be more than 100 char" do
    @user.email = "a" * 101
    assert_not @user.valid?
  end

  test "password should have a minimum and maximum length" do
    @user.password = @user.password_confirmation = "a" * 7
    assert_not @user.valid?
    @user.password = @user.password_confirmation = "a" * 51
    assert_not @user.valid?
    @user.password = @user.password_confirmation = " " * 8
    assert_not @user.valid?
    @user.password = @user.password_confirmation = "a" * 8
    assert @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email address should be unique" do
    dup_user = @user.dup
    @user.save
    assert_not dup_user.valid?
  end

  test "downcase email before save" do
    @user.email = 'IAMUPCASE@LOUD.COM'
    @user.save
    assert @user.email = 'iamupcase@loud.com'
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    connor = users(:connor)
    archer  = users(:archer)
    assert_not connor.following?(archer)
    connor.follow(archer)
    assert connor.following?(archer)
    assert archer.followers.include?(connor)
    connor.unfollow(archer)
    assert_not connor.following?(archer)
    # Users can't follow themselves.
    connor.follow(connor)
    assert_not connor.following?(connor)
  end

  test "feed should have the right posts" do
    connor = users(:connor)
    archer  = users(:archer)
    lana    = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert connor.feed.include?(post_following)
    end
    # Self-posts for user with followers
    connor.microposts.each do |post_self|
      assert connor.feed.include?(post_self)
    end
    # Self-posts for user with no followers
    archer.microposts.each do |post_self|
      assert archer.feed.include?(post_self)
    end
    # Posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not connor.feed.include?(post_unfollowed)
    end
  end
end
