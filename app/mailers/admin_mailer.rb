class AdminMailer < ApplicationMailer
   default(
    content_type: 'text/html',
    tag: -> (_) { action_name },
    sent_on: -> (_) { Time.current },
    from: Rails.application.credentials.support_email,
    message_stream: 'admin',
  )

  def support_question_email(question)
    @shop = question.shop
    @question = question
    mail(
      to: Rails.application.credentials.support_email,
      reply_to: question.email,
      subject: "Support question from #{@shop.shopify_domain}",
    )
  end
end
