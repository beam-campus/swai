defmodule SwaiWeb.PageController do
  use SwaiWeb, :controller


  def home(conn, _params) do
    redirect(conn, to: "/my_workspace")
  end


end
