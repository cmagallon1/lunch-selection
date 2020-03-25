require 'test_helper'
require 'sidekiq/testing'

class MealMailerTest < ActionMailer::TestCase

  def test_job_being_enqueued_correctly
    assert_equal 0, Sidekiq::Queues['emails'].size
    Sidekiq::Client.push(
      'class' => 'MealMailer',
      'queue' => 'emails',
      'args' => [1]
    )
    assert_equal 1, Sidekiq::Queues['emails'].size
    assert_equal 'MealMailer', Sidekiq::Queues['emails'].first['class']
    Sidekiq::Queues['emails'].clear
  end

  def test_send_email_to_users
    user = build(:user, email: 'cmagallon@ucol.mx')
    user.save
    User.all.each do |user|
      email = MealMailer.with(user: user).monthly_package
      email.to = user.email
      assert_emails 1 do
        email.deliver_now
      end
    end
  end
end
