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

    def self.check_duplicate_share(url_share, user_email)
        youtube_id = get_youtube_id_by_url(url_share)
        return unless youtube_id

        find_by(youtube_id: youtube_id, user_email: user_email)
    end

    def self.get_youtube_id_by_url(url_share)
        youtube_id = url_share.match(%r{(?:youtu\.be/|youtube\.com/(?:embed/|v/|watch\?v=|watch\?.+&v=))([\w\-]{11})})
        youtube_id[1] if youtube_id
    end

    def send_notification(current_user)
        before = {
          description: self.description,
          title: self.title,
          url_share: self.url_share,
          user_email: self.user_email,
          username: current_user.username
        }
        after = JSON.parse(before.to_json)
        ClientPushWorker.perform_async("NotificationChannel", after)
    end
end
