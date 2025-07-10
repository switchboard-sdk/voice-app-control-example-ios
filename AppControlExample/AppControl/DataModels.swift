@objc enum TriggerType: Int  {
    case next = 0
    case back = 1
    case like = 2
    case dislike = 3
    case expand = 4
    case runtimeTriggers = 5
    case unknown = 6
}

enum LikeState {
    case neutral
    case liked
    case disliked
}

struct Item {
    let title: String
    let description: String
    var likeState: LikeState
}

class DataSource {
    static let shared = DataSource()
    
    private init() {}
    
    let movieData: [Item] = [
        Item(
            title: "Dune",
            description: "Paul Atreides, a brilliant and gifted young man born into a great destiny beyond his understanding, must travel to the most dangerous planet in the universe to ensure the future of his family and his people in this epic sci-fi saga.",
            likeState: .neutral),
        
        Item(
            title: "Jaws",
            description: "A massive great white shark terrorizes the peaceful beach town of Amity Island during the busy summer season, forcing police chief Martin Brody to team up with a marine biologist and shark hunter to track down the deadly predator.",
            likeState: .neutral),
        
        Item(
            title: "Matrix",
            description: "Computer programmer Neo discovers that reality as he knows it is actually a sophisticated simulation controlled by machines, and he must join a rebellion led by the mysterious Morpheus to free humanity from their digital prison.",
            likeState: .neutral),
        
        Item(
            title: "Tron",
            description: "Software engineer Kevin Flynn gets digitally transported inside a computer mainframe where he must navigate a dangerous digital world of programs and data, fighting in gladiatorial games to escape back to the real world.",
            likeState: .neutral),
       
        Item(
            title: "Soul",
            description: "Middle school band teacher and aspiring jazz musician Joe Gardner gets his big break to perform with a jazz legend, but a small misstep takes him from the streets of New York City to the cosmic realms where souls get their personalities.",
            likeState: .neutral),
      
        Item(
            title: "Frozen",
            description: "Princess Elsa of Arendelle possesses magical ice powers that she struggles to control, and when her abilities are accidentally revealed, she flees the kingdom while her sister Anna embarks on a perilous journey to bring her home and save their realm.",
            likeState: .neutral),
       
        Item(
            title: "Avatar",
            description: "Paralyzed marine Jake Sully joins the Avatar program on the alien world of Pandora, where he pilots a genetically engineered alien body and becomes torn between following orders and protecting the indigenous Na'vi people from human colonization.",
            likeState: .neutral),
      
        Item(
            title: "Inception",
            description: "Dom Cobb is a skilled thief who enters people's dreams to steal their secrets, but he's offered a chance to have his criminal record erased if he can achieve the seemingly impossible task of inception: planting an idea deep within someone's subconscious.",
            likeState: .neutral),
      
        Item(
            title: "Interstellar",
            description: "In a near future where Earth is becoming uninhabitable, former NASA pilot Cooper joins a secret mission through a wormhole near Saturn to find humanity a new home among the stars, facing impossible choices between saving his family and saving the human race.",
            likeState: .neutral),
    ]
}
