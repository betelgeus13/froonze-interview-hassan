module LoyaltyConstants

  EMAIL_TEMPLATE_DEFAULTS = {
    LoyaltyEmailNotification::POINTS_EARNED_TYPE => {
      subject: "You've just earned {{earning_points_amount}} points!",
      title: "You've just earned points!",
      subtitle: "Congratulations {{first_name}}, you've just earned {{earning_points_amount}} points for {{earning_action}}.",
      button_text: "Spend now",
    },

    LoyaltyEmailNotification::POINTS_SPENT_TYPE => {
      subject: "You've just redeemed a reward!",
      title: "You've just redeemed a reward!",
      subtitle: "Congratulations {{first_name}}, you've just earned the reward {{reward_name}}",
      button_text: "Use your reward now",
    },

    LoyaltyEmailNotification::BIRTHDAY_TYPE => {
      subject: "Happy Birthday!",
      title: "Happy Birthday {{first_name}}",
      subtitle: "To celebrate your special day, we've added {{earning_points_amount}} points to your account",
      button_text: "Spend now",
    },
  }

  IMPORT_ACTIONS = Set[
    RESET_IMPORT_ACTION = 'reset',
    ADD_IMPORT_ACTION = 'add',
  ].freeze
end
