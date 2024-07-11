defmodule SwaiWeb.Layouts.OldFooter do
  use SwaiWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex-shrink-0">
    <%!-- <footer class="h-[120px] w-full flex justify-center text-white px-16 py-20"> --%>
    <footer>
      <div class="w-full px-10">
        <div class="border-t-[1px] border-gray-700 w-full">
          <div class="flex items-center py-6 space-x-2">
            <img src="/images/discomco-logo.png" alt="DisComCo Logo image-only" class="h-7 w-7" />
            <p class="text-sm text-white font-brand font-regular">
              with ❤️ from <a href="https://discomco.pl" class="font-regular hover:underline">DisComCo</a>
            </p>
            <div class="px-4 space-x-3 text-xs text-ltOrange font-brand font-bold">
              <a href={~p"/mission"} class="text-red-500 hover:underline">
                Our Mission
              </a>
              <a href={~p"/terms_of_service"} class="text-red-500 hover:underline">
                Terms
              </a>
              <a href={~p"/"} class="text-red-500 hover:underline">
                Privacy
              </a>
            </div>
          </div>
        </div>
      </div>
    </footer>
    </div>
    """
  end

end
