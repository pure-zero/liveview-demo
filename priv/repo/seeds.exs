# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Phxproj.Repo.insert!(%Phxproj.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Phxproj.Cases
alias Phxproj.Repo

# Create "The Adventure of the Unholy Man" case
case_attrs = %{
  title: "The Adventure of the Unholy Man",
  slug: "unholy-man",
  active: true,
  description: "A strange preacher is found murdered in his balcony seat during a performance of Hamlet.",
  story: """
  A strange preacher had come to town, a large morocco-bound Bible under
  his arm. Scotland Yard is puzzled when the preacher is found stabbed to death
  in his balcony seat at the Playhouse during a performance of Hamlet.
       Duchess Tallcourt, who accompanied the victim to the Playhouse,dis-
  covered the body upon returning from the powder room after intermission. The
  preacher's Bible was gone; and on the floor neait)y were a German-made cigar-
  ette and a packet of aspirin.
       It was common knowledge that the Duchess, previously a benefactor of the
  Bishop of Whittenfroth, had come to support the new preacher's views. This
  greatly angered the Bishop and Duke Tallcourt.
       The Longworth Acting Troupe was performing the play, Earl Longworth in
  the lead. Longworth, a rascally cad, had been wooing the Duchess's daughter,
  Anastasia, in hopes of gaining support for his poverty-stricken troupe.
       Scotland Yard wants to know a) who killed the preacher, b) the weapon, and
  c) the motive.
       The game is afoot!
  """,
  solution: """
  The preacher was in fact a thief who had stolen the original manuscript of Hamlet from an exhibit on the Riviera, where he also acquired his tan.

  The preacher disguised the manuscript as a Bible and had Longworth authenticate it for the Duke, whom the preacher hoped would buy it. Longworth, however, in desperate need of money, killed the preacher with Hamlet's sword and stole the manuscript. Longworth, who does not smoke, planted the German made cigarette near the victim's body to throw suspicion from himself, but in the process, he accidentally dropped his packet of aspirin.

  Killer: Longworth; Weapon: Sword; Motive: Manuscript.
  """
}

{:ok, case} = Cases.create_case(case_attrs)

# Create clues for each location
clues = [
  %{
    case_id: case.id,
    location_id: "chemist",
    clue_text: "You've noticed that Earl Longworth has been coming in frequently for headache remedies - he seems to suffer from constant headaches.",
    priority: 1
  },
  %{
    case_id: case.id,
    location_id: "bank",
    clue_text: "Duke Tallcourt is one of our most valued clients. He's a well-known collector of original manuscripts and is said to pay very well for authentic pieces.",
    priority: 1
  },
  %{
    case_id: case.id,
    location_id: "carriage-depot",
    clue_text: "Just yesterday, I saw Longworth reading from a Bible to both that victim preacher and Duke Tallcourt. Seemed like he was showing them something important in it.",
    priority: 1
  },
  %{
    case_id: case.id,
    location_id: "docks",
    clue_text: "You overheard that strange preacher saying something peculiar: 'You can't judge a book by its cover.' Seemed like an odd thing for a holy man to say.",
    priority: 1
  },
  %{
    case_id: case.id,
    location_id: "hotel",
    clue_text: "You've heard from Anastasia, the Duchess's daughter - she mentioned that she did not like that strange preacher at all. Found him quite unsettling.",
    priority: 1
  },
  %{
    case_id: case.id,
    location_id: "locksmith",
    clue_text: "You've been asked about this before - one of the stage swords from the theater is missing. Someone must have taken it without permission.",
    priority: 1
  },
  %{
    case_id: case.id,
    location_id: "museum",
    clue_text: "Earl Longworth is well-known here - he's considered the foremost authority on the authenticity of original manuscripts. People often bring items to him for verification.",
    priority: 1
  },
  %{
    case_id: case.id,
    location_id: "newsagents",
    clue_text: "Big news recently - the original manuscript of Hamlet was stolen from an exhibit on the Riviera! It's been in all the papers. Quite valuable, that would be.",
    priority: 1
  },
  %{
    case_id: case.id,
    location_id: "park",
    clue_text: "You often see Earl Longworth here practicing his swordsmanship. He's quite skilled with a blade and comes regularly to practice.",
    priority: 1
  },
  %{
    case_id: case.id,
    location_id: "theater",
    clue_text: "You've noticed that the Bishop of Whittenfroth was in attendance at the Playhouse on the night of the murder. That's unusual for him.",
    priority: 1
  },
  %{
    case_id: case.id,
    location_id: "boars-head",
    clue_text: "Earl Longworth has been frequenting this place several times in the last month, and from what I can tell, he appears to be having serious money troubles. Been quite worried-looking.",
    priority: 1
  },
  %{
    case_id: case.id,
    location_id: "tobacconist",
    clue_text: "The Bishop of Whittenfroth is one of my regular customers - he smokes those German-made cigarettes, quite particular about them. Also, that preacher had quite a handsome tan, which was peculiar for someone in London this time of year.",
    priority: 1
  }
]

Enum.each(clues, fn clue_attrs ->
  Cases.create_clue(clue_attrs)
end)

IO.puts("Seeded database with 'The Adventure of the Unholy Man' case and #{length(clues)} clues.")
