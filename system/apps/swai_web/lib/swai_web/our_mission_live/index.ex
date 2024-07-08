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

     <div class="lt-section-header">
       One AI, or another...
     </div>
     <div class="lt-section-text">
     <span>
     Welcome to Swarm Wars, a platform for decentralized, evolutionary AI.
     <br/>
     Though genetic AI doesn't enjoy the same media exposure as the generative kind,
     it does have the potential to be a better fit for solving problems
     in changing environments, that require self-learning and adapting agents.
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
    Though Swarm Wars is presented as a game, it is more than just that;
    by introducing competitive and entertaining elements,
    we aim to make the subject matter more accessible and engaging to a broader audience.
    <br/>
    Under the hood, it is rather a sophisticated research tool, designed to explore the complexities and potentials
    of decentralized AI systems and by studying their emergent behaviors and capabilities,
    we grow insights that can be applied to real-world challenges.
    <br/>
    The applicability of genetic algorithms is vast, ranging from optimizing logistics or trade,
    over health and environmental related topics, to enhancing autonomous systems.
    </span>
    </div>



    <div class="lt-section-header">
        We Need You!
    </div>
    <div class="lt-section-text">
    <span>
    We believe that AI should not be the exclusive domain of big tech:
    a democratization that is essential to ensure that expertise is widely distributed and decentralized,
    so that development is guided by a broad spectrum of perspectives and values.
    <br/>
    <a class="text-blue-300 hover:underline" href="https://www.buymeacoffee.com/beamologist">Your support</a> will allow us to build
    an independent and entertaining, though serious tool for research, education and problem-solving.
    </span>
    </div>

    <div class="lt-section-header">
       Shoulders of Giants
     </div>
     <div class="lt-section-text">
     <span>
     We draw inspiration from the pioneering work
     by <a class="text-blue-300 hover:underline" href="https://mitpressbookstore.mit.edu/book/9780262581110">John Henry Holland</a> and from modern advancements as described
     by <a class="text-blue-300 hover:underline" href="https://link.springer.com/book/10.1007/978-1-4614-4463-3">Gene Sher</a>
     and <a class="text-blue-300 hover:underline" href="https://pragprog.com/titles/smgaelixir/genetic-algorithms-in-elixir/">Sean Moriarity</a>.
     <br />
     These are some of the trailblazers that have paved the way for us to explore the potential of genetic algorithms.
     Not mentioning these people would be a disservice to the field and to the community.
     </span>
     </div>


     <div class="lt-section-header">
       Why the BEAM?
    </div>
    <div class="lt-section-text">
    <span>
    Our choice for the <a class="text-blue-300 hover:underline" href="https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)">'BEAM'</a> is no coincidence.
    <br />
    This platform remains unrivalled for building scalable, fault-tolerant distributed systems with requirements for high availability.
    <br />
    In addition, the ecosystem not just offers a number of libraries and tools that are well-suited for building decentralized AI systems,
    it is also very cost-efficient and capable of running on a wide range of hardware, making it resource-friendly and sustainable as well.
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
