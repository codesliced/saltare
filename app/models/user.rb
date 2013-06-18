class User < ActiveRecord::Base
  include BCrypt
  # make sure the user table has a password_hash column

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(pass)
    @password = Password.create(pass)
    self.password_hash = @password
  end

  def self.create(params={})
    @user = User.new(params)
    @user.password = params[:password]
    @user.save!
    @user
  end

  def self.authenticate(params)
    # can be changed to find user by anything unique, e.g. email or username
    user = User.find_by_name(params[:name])
    (user && user.password == params[:password]) ? user : nil
  end
end
