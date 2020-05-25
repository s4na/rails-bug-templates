# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  # Activate the gem you are reporting the issue against.
  gem "activerecord", "6.0.0"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments

  def one_comment
    comments.find_by(id: 1)
  end
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < Minitest::Test
  def setup
    # ActiveRecord::Base.logger = Logger.new(STDOUT)

    post = Post.create!
    post.comments << Comment.create!
  end

  def test_association_stuff
    posts = Post.includes(:comments)

    p posts.first.comments

    # ここでsqlが走って欲しくなかった
    p '=' * 20
    p posts.first.one_comment
  end
end
