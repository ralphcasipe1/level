defmodule Bridge.Connections do
  @moduledoc """
  A context for exposing connections between nodes.
  """

  @doc """
  Fetch users belonging to given team.
  """
  def users(team, args, context \\ %{}) do
    Bridge.Connections.Users.get(team, args, context)
  end

  @doc """
  Fetch drafts belonging to a given user.
  """
  def drafts(user, args, context \\ %{}) do
    Bridge.Connections.Drafts.get(user, args, context)
  end
end
