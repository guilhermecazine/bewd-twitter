class SessionsController < ApplicationController
  def create
    @user = User.find_by(username: session_params[:username])
    if @user && BCrypt::Password.new(@user.password) == session_params[:password]
      session = @user.sessions.create
      cookies.permanent.signed[:twitter_session_token] = session.token
      render json: { success: true }
    else
      render json: { success: false }, status: :unauthorized
    end
  end

  def authenticated
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)
    if session
      render json: { authenticated: true, username: session.user.username }
    else
      render json: { authenticated: false }
    end
  end

  def destroy
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)
    if session
      session.destroy
      render json: { success: true }
    else
      render json: { success: false }, status: :not_found
    end
  end

  private

  def session_params
    params.require(:user).permit(:username, :password)
  end
end
