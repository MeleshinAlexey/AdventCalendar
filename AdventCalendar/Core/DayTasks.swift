//
//  DayTasks.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/23/26.
//

import Foundation

struct DayTasks {

    struct Task {
        let text: String
    }

    /// Returns the task for the given topic and day (1...30).
    static func task(topic: Topic, day: Int) -> Task {
        guard (1...30).contains(day), let list = tasks[topic], list.count == 30 else {
            return Task(text: "Task not found")
        }
        return list[day - 1]
    }

    // MARK: - Data

    /// Topic mapping:
    /// - .newYear -> Christmas (December Magic)
    /// - .winter -> Winter (Cozy & Reflective)
    /// - .summer -> Summer (Joy & Lightness)
    /// - .fun -> Joy & Play (Fun & Lighthearted)
    /// - .productivity -> Productivity (Gentle & Sustainable)
    private static let tasks: [Topic: [Task]] = [
        .newYear: christmas,
        .winter: winter,
        .summer: summer,
        .fun: fun,
        .productivity: productivity
    ]

    private static let christmas: [Task] = [
        Task(text: "Write a letter to your future self—open it next Christmas."),
        Task(text: "Bake or buy one festive treat and savor it slowly."),
        Task(text: "Text someone a holiday memory you share."),
        Task(text: "Decorate one small thing (a mug, notebook, window)."),
        Task(text: "Listen to a classic Christmas song you haven’t heard in years."),
        Task(text: "Light a candle and sit quietly for 5 minutes."),
        Task(text: "Leave a kind note for a delivery person or neighbor."),
        Task(text: "Wrap a “gift” for yourself—a book, tea, or cozy socks."),
        Task(text: "Watch 10 minutes of snowfall (real or on YouTube)."),
        Task(text: "Say “thank you” to someone who made your year brighter."),
        Task(text: "Make hot cocoa with extra marshmallows."),
        Task(text: "Draw a tiny Christmas tree—even if you’re “bad” at drawing."),
        Task(text: "Donate one unused item to charity."),
        Task(text: "Sing (or hum) a carol in the shower."),
        Task(text: "Write down 3 things that felt like “magic” this year."),
        Task(text: "Call a family member just to hear their voice."),
        Task(text: "Wear something red or green today."),
        Task(text: "Write a forgiveness note—to someone else or yourself."),
        Task(text: "Stargaze for 3 minutes (even from your window)."),
        Task(text: "Make a paper snowflake and tape it somewhere joyful."),
        Task(text: "Play a board game or puzzle—alone or with someone."),
        Task(text: "Leave your porch light on “for travelers.”"),
        Task(text: "Rewatch your favorite holiday movie scene."),
        Task(text: "Give yourself a 5-minute hand massage."),
        Task(text: "Write one wish for the world in 2026."),
        Task(text: "Bake cookies and leave them for a neighbor."),
        Task(text: "Listen to sleigh bells or crackling fire sounds."),
        Task(text: "Reconnect with an old tradition—or invent a new one."),
        Task(text: "Say “Merry Christmas” to a stranger (cashier, barista, etc.)."),
        Task(text: "Sit in silence and remember: you made it through another year.")
    ]

    private static let winter: [Task] = [
        Task(text: "Brew herbal tea and watch the steam rise."),
        Task(text: "Walk outside and notice 3 winter textures (frost, bark, wool)."),
        Task(text: "Write a haiku about today’s sky."),
        Task(text: "Organize one drawer—gently, without judgment."),
        Task(text: "Listen to a winter-themed podcast or story."),
        Task(text: "Wrap your hands around a warm mug—no phone allowed."),
        Task(text: "Write down one thing you’re releasing this season."),
        Task(text: "Take a photo of something beautifully simple outside."),
        Task(text: "Wear your softest sweater today."),
        Task(text: "Light a candle and journal one hope for spring."),
        Task(text: "Make soup from scratch or improvise with what’s in your pantry."),
        Task(text: "Send a “thinking of you” text to someone quiet lately."),
        Task(text: "Stretch for 3 minutes in front of a window."),
        Task(text: "Listen to the sound of silence for 2 full minutes."),
        Task(text: "Write a tiny poem on a sticky note—leave it somewhere."),
        Task(text: "Declutter your digital desktop or phone home screen."),
        Task(text: "Watch the sunrise or sunset—just you and the light."),
        Task(text: "Try a new hot drink (chai, matcha, spiced cider)."),
        Task(text: "Fold origami snowflakes or stars—no purpose, just play."),
        Task(text: "Forgive yourself for one small mistake this week."),
        Task(text: "Rearrange your bookshelf by color or mood."),
        Task(text: "Walk without headphones—listen to the world."),
        Task(text: "Write a letter to your past self from 1 year ago."),
        Task(text: "Make your bed with extra care today."),
        Task(text: "Practice “slow looking”—study one object for 60 seconds."),
        Task(text: "Donate winter clothes you no longer wear."),
        Task(text: "Cook a meal using only 3 ingredients."),
        Task(text: "Sit near a window and watch the world go by."),
        Task(text: "Write down: “What do I need most right now?” Answer honestly."),
        Task(text: "End the month by whispering: “I am enough.”")
    ]

    private static let summer: [Task] = [
        Task(text: "Eat a piece of fruit outside—no rush."),
        Task(text: "Dance to one song with all the windows open."),
        Task(text: "Write your name in the sand (real or imaginary)."),
        Task(text: "Take a photo of your feet in grass, sand, or sun."),
        Task(text: "Buy a single flower and put it in a glass of water."),
        Task(text: "Skip (yes, skip!) for 10 steps."),
        Task(text: "Watch clouds for 3 minutes—what shapes do you see?"),
        Task(text: "Wear sunglasses even if it’s not sunny—just for fun."),
        Task(text: "Write a postcard to a friend (mail it or keep it)."),
        Task(text: "Make a “summer playlist” with 5 songs that feel like joy."),
        Task(text: "Eat ice cream slowly—lick, don’t bite."),
        Task(text: "Write down 3 tiny wins from this week."),
        Task(text: "Go barefoot for 5 minutes (grass, sand, or cool floor)."),
        Task(text: "Blow bubbles (with gum or a wand)."),
        Task(text: "Take a “sun bath”—sit in sunlight for 10 minutes."),
        Task(text: "Text a friend a memory that makes you smile."),
        Task(text: "Wear your brightest color today."),
        Task(text: "Watch the sunset with no screen—just you."),
        Task(text: "Make lemonade or iced tea from scratch."),
        Task(text: "Draw a tiny sun somewhere unexpected (notebook, napkin)."),
        Task(text: "Call someone just to say “I saw something that reminded me of you.”"),
        Task(text: "Lie on your back and watch leaves move in the wind."),
        Task(text: "Write a wish on a piece of paper—toss it in water or keep it."),
        Task(text: "Eat a meal outside—even if it’s just your balcony."),
        Task(text: "Smile at 3 strangers today."),
        Task(text: "Watch a firefly (or look up videos if you can’t find one)."),
        Task(text: "Take a “yes day” moment: say yes to one small joy."),
        Task(text: "Write a love letter to summer."),
        Task(text: "Do something slowly that you usually rush (brushing hair, washing hands)."),
        Task(text: "End the month by saying: “I let the light in.”")
    ]

    private static let fun: [Task] = [
        Task(text: "Make a silly face in the mirror—and laugh at yourself."),
        Task(text: "Sing loudly in the shower (or car)."),
        Task(text: "Blow up a balloon and write a joke on it."),
        Task(text: "Do a handstand (or attempt one!)."),
        Task(text: "Text a friend a meme that made you snort."),
        Task(text: "Wear mismatched socks on purpose."),
        Task(text: "Make a fort with blankets—even if you’re “too old.”"),
        Task(text: "Eat dessert before dinner (just today!)."),
        Task(text: "Do 3 cartwheels (or spin in a circle 5 times)."),
        Task(text: "Call someone and speak in a funny accent for 1 minute."),
        Task(text: "Draw a mustache on a celebrity photo (in your mind or on paper)."),
        Task(text: "Jump on a trampoline—or jump on the spot 20 times."),
        Task(text: "Watch a funny animal video and really laugh."),
        Task(text: "Write a haiku about your lunch."),
        Task(text: "Dance like no one’s watching (even if they are)."),
        Task(text: "Make a paper airplane and launch it."),
        Task(text: "Whisper a secret to a plant."),
        Task(text: "Eat a snack with your non-dominant hand."),
        Task(text: "Take a photo of something absurd in your home."),
        Task(text: "Tell yourself a joke—and laugh at the punchline."),
        Task(text: "Wear a hat indoors all day."),
        Task(text: "Make up a 30-second dance and perform it."),
        Task(text: "Write a fake award for yourself (“Best Smiler of 2025”)."),
        Task(text: "Blow bubbles with chewing gum."),
        Task(text: "Do a “compliment bomb”: give 3 genuine compliments today."),
        Task(text: "Play a childhood game (hopscotch, tag, rock-paper-scissors)."),
        Task(text: "Make a silly voice note to yourself—listen later."),
        Task(text: "Rearrange your furniture “wrong” for one hour."),
        Task(text: "Eat breakfast for dinner (pancakes at 8 PM? Yes!)."),
        Task(text: "End the month by saying: “I chose joy—and joy chose me back.”")
    ]

    private static let productivity: [Task] = [
        Task(text: "Write your top 1 priority for today—then do it first."),
        Task(text: "Delete 10 unused apps or old files."),
        Task(text: "Set a timer for 25 minutes—work on one thing only."),
        Task(text: "Write down 3 tasks you’ll not do today (protect your energy)."),
        Task(text: "Organize your desktop or phone home screen."),
        Task(text: "Reply to one overdue email—keep it under 3 sentences."),
        Task(text: "Break a big task into 3 tiny steps—do step 1."),
        Task(text: "Say “no” to one non-essential request (in your mind or out loud)."),
        Task(text: "Clear your physical desk for 5 minutes."),
        Task(text: "Schedule a 15-minute break—and actually take it."),
        Task(text: "Write tomorrow’s top 3 tasks—then close your notebook."),
        Task(text: "Unsubscribe from 3 email newsletters."),
        Task(text: "Do a “power tidy”: clear one surface completely."),
        Task(text: "Turn off non-essential notifications for 2 hours."),
        Task(text: "Ask yourself: “Is this urgent—or just loud?”"),
        Task(text: "Batch similar tasks (calls, replies, errands) into one block."),
        Task(text: "Write a template for a recurring email you send often."),
        Task(text: "Forgive yourself for not doing “enough” yesterday."),
        Task(text: "Set a “stop time” for work today—and honor it."),
        Task(text: "Replace one “I have to” with “I choose to.”"),
        Task(text: "Declutter your digital photos: delete 20 blurry ones."),
        Task(text: "Write a 2-sentence daily plan—no more, no less."),
        Task(text: "Do the 2-minute rule: if it takes <2 min, do it now."),
        Task(text: "Block 30 minutes for deep work in your calendar."),
        Task(text: "Celebrate one small win—out loud or in writing."),
        Task(text: "Close all browser tabs you don’t need right now."),
        Task(text: "Ask: “What can I delegate or delete?” (Even if just mentally.)"),
        Task(text: "End your workday with a ritual (tea, stretch, shutdown phrase)."),
        Task(text: "Write: “My worth isn’t tied to my output.” Read it twice."),
        Task(text: "Finish the month by saying: “I worked with kindness—to myself and my time.”")
    ]
}
