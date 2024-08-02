class TweetsController < ApplicationController
  before_action :authenticate_user, only: [:create, :destroy, :index_by_user]

  def index_by_user
    user = User.find_by(username: params[:username])

    if user
      tweets = user.tweets.order(created_at: :desc)
      render json: {
        tweets: tweets.map do |tweet|
          {
            id: tweet.id,
            username: user.username,
            message: tweet.message
          }
        end
      }
    else
      render json: { success: false }, status: :not_found
    end
  end

  def create
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)

    if session
      user = session.user
      @tweet = user.tweets.new(tweet_params)

      if @tweet.save
        render json: {
          tweet: {
            username: user.username,
            message: @tweet.message
          }
        }
      else 
        render json: { success: false }
      end 
    else 
      render json: { success: false }
    end 
  end

  def destroy
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)

    if session 
      user = session.user
      @tweet = Tweet.find_by(id: params[:id])

      if @tweet&.destroy
        render json: { success: true }
      else
        render json: { success: false }
      end
    else
      render json: { success: false }
    end 
  end

  def index
    @tweets = Tweet.all.order(created_at: :desc)
    render json: {
      tweets: @tweets.map do |tweet|
        {
          id: tweet.id,
          username: tweet.user.username,
          message: tweet.message
        }
      end
    }
  end

  private 

    def tweet_params
      params.require(:tweet).permit(:message)
    end 

    def authenticate_user
      unless current_user
        render json: { success: false }, status: :unauthorized
      end
    end

    def current_user
      token = cookies.signed[:twitter_session_token]
      session = Session.find_by(token: token)
      session&.user
    end
end
