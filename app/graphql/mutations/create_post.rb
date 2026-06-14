# frozen_string_literal: true

# mutation {
#   createPost(input: {
#     title: "XYZ",
#     content: "..."
#   }) {
#     post {
#       id
#       title
#       content
#     }
#     errors
#   }
# }

module Mutations
  class CreatePost < BaseMutation
    argument :title, String, required: true, validates: { allow_blank: false }
    argument :content, String, required: true, validates: { allow_blank: false }

    field :post, Types::PostType, null: false
    field :errors, [ String ], null: false

    def resolve(title:, content:)
      post = Post.new title: title, content: content
      if post.save
        { post: post, errors: [] }
      else
        { post: nil, errors: post.errors.full_messages }
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("RecordInvalid: #{e.record.class}: #{e.record.errors.full_messages.join(", ")}")
      #   # GraphQL::ExecutionError.new("Invalid input: #{e.record.class}: #{e.record.errors.full_messages.join(", ")}")
      #   { post: nil, errors: e.errors.full_messages }
    end
  end
end
