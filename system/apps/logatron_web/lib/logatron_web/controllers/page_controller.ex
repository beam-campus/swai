defmodule LogatronWeb.PageController do
  use LogatronWeb, :controller


  def home(conn, _params) do
    redirect(conn, to: "/about")
  end


end
