defmodule AshHqWeb.Pages.Home do
  @moduledoc "The home page"

  use Surface.LiveComponent

  alias AshHqWeb.Components.{CalloutText, CodeExample, SearchBar}
  import AshHqWeb.Components.CodeExample, only: [to_code: 1]

  def render(assigns) do
    ~F"""
    <div>
      <div class="w-full bg-orange-600 text-center py-2 text-lg font-semibold">
        This site is still under construction and is live for preview purposes only.
      </div>
      <div class="my-2 dark:bg-primary-black dark:bg-dark-grid bg-light-grid px-12 flex flex-col items-center pt-36">
        <div class="text-5xl font-bold max-w-5xl mx-auto mt-2 text-center">
          Build <CalloutText>powerful</CalloutText> and <CalloutText>extensible</CalloutText> Elixir applications with a next generation tool-chain.
        </div>
        <div class="text-xl font-light text-gray-700 dark:text-gray-400 max-w-4xl mx-auto mt-4 text-center">
          A declarative foundation for modern applications. Use extensions like <CalloutText>Ash GraphQL</CalloutText> and <CalloutText>Ash Json Api</CalloutText> to add APIs in minutes,
          or build your own extensions. Plug-and-play with other excellent tools like <CalloutText>Phoenix</CalloutText> and <CalloutText>Absinthe</CalloutText>.
        </div>
        <SearchBar class="hidden sm:block mt-16" />

        <div class="pt-6 pb-6 w-full hidden sm:block mt-36">
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-10">
            <CodeExample
              id="define-a-resource"
              class="grow min-w-fit max-w-[1000px]"
              code={post_example()}
              title="Define a resource"
            />
            <div class="flex flex-col space-y-8">
              <CodeExample
                class="w-auto"
                collapsible
                id="use-it-programmatically"
                code={changeset_example()}
                title="Use it programmatically"
              />
              <CodeExample
                class="w-auto"
                collapsible
                id="graphql-interface"
                code={graphql_example()}
                title="Add a GraphQL interface"
              />
              <CodeExample
                class="w-auto"
                collapsible
                start_collapsed
                id="authorization-policies"
                code={policies_example()}
                title="Add authorization policies"
              />
              <CodeExample
                class="w-auto"
                collapsible
                start_collapsed
                id="aggregates"
                code={aggregate_example()}
                title="Define aggregates and calculations"
              />
              <CodeExample
                class="w-auto"
                collapsible
                start_collapsed
                id="pubsub"
                code={notifier_example()}
                title="Broadcast changes over Phoenix PubSub"
              />
              <CodeExample
                class="w-auto"
                collapsible
                start_collapsed
                id="live-view"
                code={live_view_example()}
                title="Use it with Phoenix LiveView"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @changeset_example """
                     post = Example.Post.create!(%{
                       text: "Declarative programming is fun!"
                     })

                     Example.Post.react!(post, %{type: :like})

                     Example.Post
                     |> Ash.Query.filter(likes > 10)
                     |> Ash.Query.sort(likes: :desc)
                     |> Example.read!()
                     """
                     |> to_code()

  defp changeset_example do
    @changeset_example
  end

  @live_view_example """
                     def mount(_params, _session, socket) do
                       form = AshPhoenix.Form.for_create(Example.Post, :create)

                       {:ok, assign(socket, :form, form}}
                     end

                     def handle_event("validate", %{"form" => input}, socket) do
                       form = AshPhoenix.Form.validate(socket.assigns.form, input)

                       {:ok, assign(socket, :form, form)}
                     end

                     def handle_event("submit", _, socket) do
                       case AshPhoenix.Form.submit(socket.assigns.form) do
                         {:ok, post} ->
                           {:ok, redirect_to_post(socket, post)}

                         {:error, form_with_errors} ->
                           {:noreply, assign(socket, :form, form_with_errors)}
                       end
                     end
                     """
                     |> to_code()
  defp live_view_example do
    @live_view_example
  end

  @graphql_example """
                   graphql do
                     type :post

                     queries do
                       get :get_post, :read
                       list :feed, :read
                     end

                     mutations do
                       create :create_post, :create
                       update :react_to_post, :react
                     end
                   end
                   """
                   |> to_code()
  defp graphql_example do
    @graphql_example
  end

  @policies_example """
                    policies do
                      policy action_type(:read) do
                        authorize_if expr(visibility == :everyone)
                        authorize_if relates_to_actor_via([:author, :friends])
                      end
                    end
                    """
                    |> to_code()
  defp policies_example do
    @policies_example
  end

  @notifier_example """
                    pub_sub do
                      module ExampleEndpoint
                      prefix "post"

                      publish_all :create, ["created"]
                      publish :react, ["reaction", :id] event: "reaction"
                    end
                    """
                    |> to_code()
  defp notifier_example do
    @notifier_example
  end

  @aggregate_example """
                     aggregates do
                       count :likes, :reactions do
                         filter expr(type == :like)
                       end

                       count :dislikes, :reactions do
                         filter expr(type == :dislike)
                       end
                     end

                     calculations do
                       calculate :like_ratio, :float do
                         expr(likes / (likes + dislikes))
                       end
                     end
                     """
                     |> to_code()

  defp aggregate_example do
    @aggregate_example
  end

  @post_example """
                defmodule Example.Post do
                  use AshHq.Resource,
                    data_layer: AshPostgres.DataLayer

                  postgres do
                    table "posts"
                    repo Example.Repo
                  end

                  attributes do
                    attribute :text, :string do
                      allow_nil? false
                    end

                    attribute :visibility, :atom do
                      constraints [
                        one_of: [:friends, :everyone]
                      ]
                    end
                  end

                  actions do
                    update :react do
                      argument :type, Example.Types.ReactionType do
                        allow_nil? false
                      end

                      change manage_relationship(
                        :type,
                        :reactions,
                        type: :append
                      )
                    end
                  end

                  relationships do
                    belongs_to :author, Example.User do
                      required? true
                    end

                    has_many :reactions, Example.Reaction
                  end
                end
                """
                |> to_code()

  defp post_example do
    @post_example
  end
end
