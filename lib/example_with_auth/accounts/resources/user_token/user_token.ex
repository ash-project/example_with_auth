defmodule ExampleWithAuth.Accounts.UserToken do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: [ExampleWithAuth.Accounts.EmailNotifier]

  alias ExampleWithAuth.Accounts.UserToken.Changes
  alias ExampleWithAuth.Accounts.Preparations

  postgres do
    table "user_tokens"
    repo ExampleWithAuth.Repo
  end

  identities do
    identity :token_context, [:context, :token]
  end

  actions do
    read :default, primary?: true

    read :verify_email_token do
      argument :token, :url_encoded_binary, allow_nil?: false
      argument :context, :string, allow_nil?: false
      prepare Preparations.SetHashedToken
      prepare Preparations.DetermineDaysForToken

      filter(
        expr do
          token == ^context(:hashed_token) and context == ^arg(:context) and
            created_at > ago(^context(:days_for_token), :day)
        end
      )
    end

    create :build_session_token do
      primary? true
      accept [:user]

      change set_attribute(:context, "session")
      change Changes.BuildSessionToken
    end

    create :build_email_token do
      accept [:sent_to, :context, :user]

      change Changes.BuildHashedToken
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :token, :binary
    attribute :context, :string
    attribute :sent_to, :string

    create_timestamp :created_at
  end

  relationships do
    belongs_to :user, ExampleWithAuth.Accounts.User
  end
end
