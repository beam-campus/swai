defmodule SwaiWeb.OurMissionLive.Index do
  use SwaiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign(page_title: "Our Mission")}

      false ->
        {:ok,
         socket
         |> assign(page_title: "Our Mission")}
    end
  end

  @impl true
  def handle_info(_msg, socket) do
    {
      :noreply,
      socket
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
    class="m-10 py-10 px-5 bg-gray-700 bg-opacity-50 rounded-lg shadow-xl"
    id="mission-card"
    >

    <%!-- <div class="flex-grow"> --%>


     <div class="lt-section-header">
       One AI, or another...
     </div>
     <div class="lt-section-text">
     <span>
     Welcome to Swarm Wars, a platform for decentralized, evolutionary AI.
     <br/>
     Though genetic AI doesn't enjoy the same media exposure as the generative kind,
     it does have the potential to assist in solving a whole different slew of problems.
     <br/>
     Problems that require real-time, adaptive solutions to ever changing environments.
     <br/>
     Our mission is to create a community that is interested to further this field,
     with the ideal of being able to apply what we learn to real-world problems.
     </span>
     </div>


     <div class="lt-section-header">
        More than a Game
    </div>
    <div class="lt-section-text">
    <span>
    Swarm Wars is more than just a game;
    it is a sophisticated research tool, designed to explore the complexities and potentials
    of decentralized AI systems.
    By studying the emergent behaviors and capabilities of these systems,
    we hope to unlock new insights that can be applied to real-world challenges,
    ranging from optimizing logistics or trade, over health and environmental related topics, to enhancing autonomous systems.
    <br />
    The choice for the Erlang Ecosystem as our technological foundation reflects our commitment
    to building robust, distribution-friendly and cost-efficient solutions that
    align with our vision for a more decentralized, resource-friendly and sustainable AI landscape.
    </span>
    </div>


    <div class="lt-section-header">
        Crowdfunding the Future
    </div>
    <div class="lt-section-text">
    <span>
    We build on the principle that AI should not be the exclusive domain of big tech.
    <br />
    We believe that its potential should be accessible to everyone,
    fostering a community of visionaries, innovators, researchers and enthusiasts.
    This democratization is essential to ensure that its benefits are widely distributed
    and that its development is guided by a broad spectrum of perspectives and values.
    <br/>
    This is why we are turning to crowdfunding: it embodies the very principles of decentralization and community involvement that underpin our vision.
    In addition, leveraging the gaming aspect as an additional source of income.
    <br/>
    By relying on the collective support of individuals who share our passion,
    we can stay independent and true to our mission to build a community-driven platform
    that is accountable to its users only.
    <br />
    Your support will enable us to develop and enhance Swarm Wars,
    ensuring that it becomes and remains a cutting-edge tool for research, education and problem-solving.
    <br/>
    Thank you for your support.
    </span>
    </div>

    <div class="lt-section-header">
       Shoulders of Giants
     </div>
     <div class="lt-section-text">
     <span>
     We draw inspiration from the pioneering work
     by <a class="hover:underline" href="https://mitpressbookstore.mit.edu/book/9780262581110">John Henry Holland</a> and from modern advancements as described
     by <a class="hover:underline" href="https://link.springer.com/book/10.1007/978-1-4614-4463-3">Gene Sher</a>
     and <a class="hover:underline" href="https://pragprog.com/titles/smgaelixir/genetic-algorithms-in-elixir/">Sean Moriarity</a>.
     <br />
     These are some of the trailblazers that have paved the way for us to explore the potential of genetic algorithms.
     Not mentioning these people would be a disservice to the field and to the community.
     </span>
     </div>



    <%!-- <div class="lt-section-header">
        Guilty as charged
    </div>
    <div class="flex px-20" >
    <div class="w-100">
        <img src="/images/raf1.jpg" alt="Beamologist" class="border rounded-full w-50 h-50 border-white" />
    </div>
    <div class="lt-section-text">
        Beamologist, a software engineer with decades of experience in
        developing corporate web- and edge/IoT applications using .NET,
        mostly in logistics- and manufacturing related industries.
        <br />
        Come 2020, he was looking for answers to solve needs in the fields of event-driven architectures,
        decentralized systems and genetic algorithms. This is when he discovered the BEAM ecosystem.
        Ever since, he realized that other platforms would probably
        not be able to offer a similar coverage and quality,
        or even bring the same amount of professional satisfaction.
        This is when he decided to dedicate his time to contribute to initiatives that further the ecosystem.
    </div>
    </div> --%>
    <%!-- </div>     --%>
    </div>
    """
  end
end
