class Movie < ApplicationRecord
    has_many :user_movies

    def like_action user
        return 'none' if user.nil?
        usm = user_movies.where(user_id: user.id)
        return 'none' unless usm.any?
        return usm.first.action_type
    end

    def as_json user
        {
            id: id,
            title:         title,
            description:         description,
            url_share:         url_share,
            youtube_id:         youtube_id,
            user_email:         user_email,
            info:         info,
            created_at:         created_at,
            updated_at:         updated_at,
            like_action:         like_action(user),
        }
    end
end
