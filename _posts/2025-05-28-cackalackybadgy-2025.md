---
layout: post
title: "Cackalackybadgy: Baby's first firmware development"
date: 2025-05-28
tags: [badgelife, c, cpp, cackalackycon, lockfale, embedded, gamedev]
---

# Cackalackybadgy: Baby's first firmware development

With the most prominent example being Defcon, you'll see security conference attendees sporting a circuit board that probably _does something neat_ while also acting as a token of entry to the event. You might see other badges for special parties or repping membership to specific crews. Some badges you can buy with monies, some you can win in raffles, some you come about through contests or an exchange. This is a story about how a lifelong n00b chanced into that last category.

![The green ones are the hard-to-get ones](/assets/images/2025/05/cackalackybadgy-2025/IMG_0453.jpg)

I love badges for the artistry that the makers put into them, from the circuit design to the challenges coded within, the screenprinted art on top, there's something plumb dumb neat about purpose made hardware. I've seen badges that act as [CAN bus](https://en.wikipedia.org/wiki/CAN_bus) interfaces, breathalyzers, light show displays, and game controllers... I've seen badges hacked to play laser tag, fly quadcopters, and whistle the mosquito tone (~20KHz) at nearby passer-byers to "test their hearing". I've never been an electrical engineer, hardware hacking is a dark art that I pretend to practice when soldering together kit projects like effects pedals, radio shit, maybe an AV toy.

## "So, do you want to write badge firmware?"

It's January 2025, I've been out of work for a few months, and [melvin2001](https://github.com/melvin2001) messages me asking how my C is, and if I have any interest in writing firmware for a conference badge mimicking a classic 90s toy.

> Yeah... fuck yeah. I'm in. If you idiots are willing to merge my pull requests, I'll keep submitting them.

I haven't touched C in the last ~15 years, I've never worked embedded development, and my github is an embarrassing blank mess... but I know this project is ambitious, it has had a lot of devs drop out, and it's being presented at a regional conference [CackalackyCon](https://cackalackycon.org/) that I like to get loose at. It's an opportunity to deepen skills well outside of the Incident Response scope I'm used to, and I'm looking for any way to avoid the sharp reality that I'm not earning right now (lol plz help I still really need to gain some employment). It was basically a perfect opportunity.

{% include youtube.html id="TbF29c_FpV8" %}

## Hello World

I join right as the team is abandoning RTOS for lack of good asynchronous task support on the ESP8266 design that our hardware man has put together. I get a prototype board after a long day of driving, pull the code and work out some repo permissions issues, and get the mainline building on RTOS just as the decision is made to switch over to the poorman's repo, an amalgamation of code from badges past.

I cobble together some _very comprehensive_ scripts for [platformIO](https://platformio.org/) that I can use to build/flash firmware, and another to establish a serial connection to the badge. Our hardware has some fun bits: four buttons, four NeoPixels, an [SSD1306](https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf) OLED screen, a [LIS2DW12](https://www.st.com/resource/en/datasheet/lis2dw12.pdf) motion sensor, a [haptic motor](https://www.adafruit.com/product/1201?gQT=1), and a [DS9092](https://www.analog.com/media/en/technical-documentation/data-sheets/DS9092-DS9092T.pdf) iButton probe which would be used in conjunction with [DS1971](https://www.analog.com/media/en/technical-documentation/data-sheets/DS1971.pdf) iButtons (dallas keys) distributed with badges to conference attendees.

## Real time developer LARPing

When I picked up my dev hardware, I got a big earful about the ibuttons and how they would be used as an authentication layer for badge users, with allusions to mitigations for shenanigans observed from the previous year's badge. The code for this was already written and thank gahd for that, because it sounded damn complicated getting the timing right with a single core microcontroller.

The badge itself will have a 90s toy game constantly running, attendees will need to nurture their Cyber Partner, else it might perish. And many will.

The badge is gonna have a backend, this sounds great. Why trust what a client tells you, when your backend can be the source of truth and you're just running a simulation on the client to yield a parallel user experience? It's like we're coding an MMORPG, but with much simpler graphics. Sounds like there are bunch of things I don't need to worry about, since there will be state syncing handled by another developer on the team. **SOUNDS GREAT**.

**So with all of this in mind,** I'm thinking my best contribution opportunities are going to be:

- Balancing the difficulty of keeping your Cyber Partner alive
- Making sure the badge _is fun_
- Documentation
- Knocking out whatever other small tasks people wanna delegate to me

### O'Grady Says

So for my first big feature, I found the code for a game on the previous year's badge which was written in C via namespaces. I knew I wanted to use NeoPixels for non lightshow purposes, and so I set out to recreate a popular children's memory game, reborn as [O'Grady Says](https://en.wikipedia.org/wiki/Simon_Says). It took me about a month of coding alone before pushing a working version, and then a friend gave me a code review through [GitHub Copilot](https://github.com/features/copilot) which found a nice memory leak. Turns out, I wasn't deallocating my array of randomly generated button sequences. This was enough to sell me on the vibe-coded future, so I installed it. Not every prompt has been a winner but I'm not looking back.

_O'Grady Says_ was a great testing ground for many components of the badge. I needed to display the remaining round time on the screen, buzz the haptic motor any time a player or the game lit a neopixel, track user inputs, generate semi-random sequences, compare the shown light pattern to player inputs, and award credits for the larger CyberPartner game on completion. The game followed an existing state machine paradigm modeled by the game ported from the '24 badge, so that commnuications with the backend wouldn't halt whenever O'Grady was running.

### Haptics and Accelerometers

So with this initial game complete, I turn to look at the code controlling two conflicting features: A motion machine, and a motion sensing chip.

Our `LIS2DW12` code was enough to read directional changes and issue interrupts whenever taps were detected by the badge hardware. Our code was in a C namespaces format and had large portions of some kind of example code commented out, so I dug around on github and found [something suspiciously close to our code from DFRobot](https://github.com/DFRobot/DFRobot_LIS/blob/master/src/DFRobot_LIS2DW12.h). Shoutout to the MIT License and the 🐐GOATS🐐 who wrote this, because every other example set I could find driving the LIS2DW12 was a horrible-to-read hodgepodge mess. I converted this all back to a C class, and added enough code to get 8bit and 12bit temperature readings working.

#### Fixing a bug that was bothering nobody

Our existing main loop and accelerometer code would throw an interrupt whenever the chip sensed a [tap event](https://www.st.com/resource/en/application_note/an5038-lis2dw12-alwayson-3axis-accelerometer-stmicroelectronics.pdf). This is cool, until the haptic motor turns on and the badge registers hundreds of taps and double taps per second, browning out your serial console with prints.

To make this go away, I modified our already classful haptic library to track the state of the motor (off/on), and added a function to return that state. In our Accelerometer code, I added state tracking for when the interrupt has been attached, and a getter/setter for the time it happened.

In the main loop, we can now detach the interrupt that's set on the accelerometer's interrupt pin, and re-enable the interrupt when the haptic state is off. We use the time functions to re-enable after a slight delay and inform print debugging.

```cpp
// Disable accelerometer interrupts while the haptic motor is running
// this eliminates legitimate HAPTAPs while the motor is on
if (BadgeHaptic::getInstance().isHapticOn()) {
    // Only detach the interrupt once per haptic
    if (BadgeAcceler::getInstance().isTapInterruptAttached()){
        detachInterrupt(digitalPinToInterrupt(ACCELEROMETER_PIN));
        BadgeAcceler::getInstance().setLastAccelerDetachTime(millis());
        BadgeAcceler::getInstance().setTapInterruptAttached(false);
}
// Otherwise the haptic is off, reattach the interrupt after 300ms
// to eliminate inertia-driven "ghost" taps
} else {
    currentTime = millis();
    if (!BadgeAcceler::getInstance().isTapInterruptAttached()) {
        if (currentTime - BadgeAcceler::getInstance().getLastAccelerDetachTime() >= 300) {
            attachInterrupt(ACCELEROMETER_PIN, sharedInterruptHandler, RISING);
            BadgeAcceler::getInstance().setTapInterruptAttached(true);
        }
    }
}
```

The best part about fixing this bug? The dev team knew it existed, but we had (or developed) no plans to use the tap sensing functionality of the badge. It was a fun learning experience, but ultimately didn't help out too much other than serving as an example for similar future issues.

#### You dropped an egg, you killed your Cyber Partner, it's a feature

But, all that haptic/accelerometer work lead me to my favorite and most cheered for feature: **Killing CyberPartners dropped in Egg state**. The LIS2DW12 will also register freefall events by throwing an interrupt if you spend the time to get data rates and sampling times dialed in nicely. Think like harddrives needing to move the write head away from the disk when the drive is being dropped. Instead of saving your drive, we're damaging your virtual pet.

Originally, I had this feature dialed in to register events on an ~18" drop (about the length of a lanyard), but we opted to desensitize it in the case that people walking up stairs, or riding elevators, horseplaying, etc wouldn't experience the death.

```cpp
// Immediately handle freefall routine/input
// If badge is actively in freefall, or freefall hasn't been fully handled, do work
if (freefall_handler_flag) {
    Serial.println("ACCEL: Free-fall detected, standing by for landing...");
    while (BadgeAcceler::getInstance().isFreeFallDetected()) {
        delay(1);
    }
    float freeFallDistance = BadgeAcceler::calculateFreeFallDistance();
    // Ignore drops less than ~4"/10cm
    if (freeFallDistance > 0.1f) {
        // Tell the user they dun goofed an dropped (or launched) the baby
        Serial.printf("ACCEL: In freefall for approx: %.2fm / %.1f\"\n", freeFallDistance, freeFallDistance * 39.3701f);
        CyberPartnerGame::getInstance().handleFreeFallEvent(freeFallDistance);
    } else {
        Serial.println("ACCEL: Freefall distance too small, ignoring.");
    }
    // Reset the handler flag
    freefall_handler_flag = false;
}
```

### Roulotto

Roulotto was the first classful game I made, a betting game where you can place one of several 1:1 bets or choose a number for a 1:36 bet. Roulotto's absolutely the worst in that:

- The wheel contains three Green numbers: `0`, `00`, and `000`
- The odds were never truly even across all numbers on the wheel
- The odds shift as you bet more money
- There's only one inside bet worth placing, depending on how much money you've committed: 17 (Black)

I'm not going to lie to you, this was 100% prompt engineering to arrive at this solution...
But it Looks Good To Me™, I've play-tested it a ton, it feels fair yet biased, call it fairly uneven. I'm legit proud of how quickly this game came together.

```cpp
float betPercentage = static_cast<float>(currentBetAmount) / playerMoney;
float singleSpecialWeight = (betPercentage * 100.0f) / 4.0f; // Divide equally among 0, 00, 000, and 17
// Initialize weights for all numbers (0 to 38)
std::vector<float> weights(39, 1.0f); // Default weight is 1.0 for all numbers

// Adjust weights for green values and 17
weights[0] += singleSpecialWeight;  // Green: 0
weights[37] += singleSpecialWeight; // Green: 00
weights[38] += singleSpecialWeight; // Green: 000
weights[17] += singleSpecialWeight; // Black: 17

// Calculate the total weight
float totalWeight = 0.0f;
for (float weight : weights) {
    totalWeight += weight;
}

// Generate a random number based on the weights, then determine the winning number
float randomValue = static_cast<float>(random(0, 10000)) / 10000.0f * totalWeight;
float cumulativeWeight = 0.0f;
for (int i = 0; i < weights.size(); i++) {
    cumulativeWeight += weights[i];
    if (randomValue <= cumulativeWeight) {
        return i; // Winning number
    }
}
```

#### Learning to handle animations

After getting the gameplay for Roulotto down, I wanted to spice it up by adding an animation during the "wheel spin" period. I knew I needed sprites, and i needed to draw the individual frames of the animation to the screen. I've never put in the time to have a talent for photoshop, but I did remember this sweet-ass web tool from [Jenn Schiffer](https://jennschiffer.com/) [[Github](https://github.com/jennschiffer)] called [make8bitart](https://make8bitart.com/) which would let me use a mouse to do the thing like the absolute troglodyte that I am. **So I paint:**

![Wheel 1](/assets/images/2025/05/cackalackybadgy-2025/RL_WHEEL_1.png) ![Wheel 2](/assets/images/2025/05/cackalackybadgy-2025/RL_WHEEL_2.png)

In all actuality, I made 8 of these instead of using my brain to rotate the images programmatically... That idea hit me after I'd already had this implemented, and I wasn't about to remove this without some kind of optimization need, because my time was better spent pressing forward on other badge features. But anyways! I've got these absolute dogspit PNGs, and now I need to get them into a machine-readable format. My partner in firmware crimes [pandatrax](https://github.com/pandatrax) blesses me with [image2cpp](http://javl.github.io/image2cpp/) by [javl](https://github.com/javl), and I'm off to the races with arrays of encoded sprites to animate.

![Wheel 2](/assets/images/2025/05/cackalackybadgy-2025/roulotto_animation_gif_from_video_terrible.gif)

Above is an early, bad example of the working animation. Notice that one frame draws slightly smaller than the other 7! That took 45 minutes to diagnose and correct.

### Game Templatization

With Roulotto done and dusted, I cut all of the game-specific content out of it and make a template for future games. Really, it would have been hella beneficial to have this done from the beginning, but I was living, I was learning, I eventually made the game template about a week before the conference. It would be crucial to the success of my next two games...

#### WeightShake and the CyberSpa

WeightShake and the CyberSpa both are less "games" in the traditional sense, but activities you can perform with your CyberPartner to influence their stats. WeightShake uses the accelerometer to count how many times you pump virtual iron, resulting in weight loss (sometimes).

CyberSpa is meant to be a simple and relaxing activity where the haptic turns on for a predetermined period, depending on what level of massage you buy. To soothe your tired eyes while your CyberPartner is resting up, we scroll the image of a maybe-white lotus across the screen until your massage timer expires. As a reward for not resetting your badge through the numbing haptic vibrations, your CyberPartner's happiness increases. _So Relaxing_.

Below are the sprites used for both of those games. They're bad, but again, I made them myself with the above mentioned tools.

![Lotus](/assets/images/2025/05/cackalackybadgy-2025/bad_lotus.png) ![bad_dumbbell](/assets/images/2025/05/cackalackybadgy-2025/bad_dumbbell.png)

### Badge Achievements

Throughout this writeup, I've mentioned a bunch of silly features that ended up becoming client-side achievements that can be unlocked and viewed from within a menu. Here's a list of them dumped from the firmware by @jhkiehna4276 (discord)

```txt
14986 0x00094dd1 0x00094dd1 18  19           ascii   helloworldUnlocked
14987 0x00094de4 0x00094de4 10  11           ascii   suUnlocked
14988 0x00094def 0x00094def 18  19           ascii   gotDroppedUnlocked
14989 0x00094e02 0x00094e02 18  19           ascii   gotStarvedUnlocked
14990 0x00094e15 0x00094e15 18  19           ascii   gotThirstyUnlocked
14991 0x00094e28 0x00094e28 20  21           ascii   gotDepressedUnlocked
14992 0x00094e3d 0x00094e3d 14  15           ascii   gotOldUnlocked
14993 0x00094e4c 0x00094e4c 16  17           ascii   gotHeavyUnlocked
14994 0x00094e5d 0x00094e5d 17  18           ascii   gotSkinnyUnlocked
14995 0x00094e6f 0x00094e6f 17  18           ascii   gotChillyUnlocked
14996 0x00094e81 0x00094e81 17  18           ascii   gotSweatyUnlocked
14997 0x00094e93 0x00094e93 18  19           ascii   beatOgradyUnlocked
14998 0x00094ea6 0x00094ea6 20  21           ascii   beatRoulottoUnlocked
14999 0x00094ebb 0x00094ebb 16  17           ascii   d3adb33fUnlocked
15000 0x00094ecc 0x00094ecc 8   9            ascii   tonyHawk
```

Let's talk about some of my favorites.

1. **Remember that bit at the beginning of this post about the onewire library melvin2001 wrote?** Turns out, a feature of that library was detecting dallas key reads that don't fully comply with the spec. I have it on good authority that there's no publicly available library (that we can find) which does, [including the one used by flipperzero](https://github.com/flipperdevices/flipperzero-firmware/blob/dev/lib/ibutton/protocols/dallas/protocol_ds1971.c). So, this badge effectively detects spoofed dallas keys, and will try to rewrite them with the hex `d3adb33f`. Hence, we must issue an achievement for anyone trying to use a flipper on the badge. **This achievement also inverts the display color scheme**, allowing for easy identification at a glance/distance of users with the achievement.
2. **beatRoulottoUnlocked** was only given to those who won an inside bet. As far as I know, no one won this achievement legitimately, but I also didn't get good metrics on the play of this game (more in a bit).
3. For users who successfully connected to the serial console of their badge, if any commands were entered incorrectly, the badge would rotate the screen display by 180 degrees, flipping the content upside down. **If you did this 5 times for a combined rotation of 900 degrees, you unlocked the achievement tonyHawk**.
4. **gotChillyUnlocked/gotSweatyUnlocked** could only be achieved by lowering or raising the temperature of our badge below 60 degrees or above 90 degrees. A few people legitimately unlocked gotSweaty, but I don't know of anyone who stuck their badge in the fridge, or used it as a drink coaster to unlock gotChilly.
5. **gotDroppedUnlocked** would only trigger if you dropped the CyberPartner while it was in egg state, cracking the egg and triggering a death event. It's an anti-game!
6. We hid all of our most powerful utilities on the badge behind a "su password". An absolute work of satan, pandatrax picked a case sensitive password `Ecruiaiergo`, which took me weeks to commit to memory, because I can't pronounce that many vowels strung together consecutively. In the end, the secret to remembering this password was to break it up into 3 little passwords: `Ecru`, `iai`, `ergo`. Accessing this mode unlocked an achievement.

#### Realizing a lil goof in feature organization

I absolutely failed to coordinate my client-driven achievements with our backend owner [persianc](https://github.com/persinac), who ended up calculating half of the same achievements regarding CyberPartner state. In the end, we reconciled event namespaces and I had the badge post to an achievements MQTT topic when unlocks were achieved, but it was definitely possible to have the two out of sync. **A lesson learned** for next year. Luckily though, I don't think most people noticed since the badge was the only user-enabled view into unlocked achievements.

### Debugging Tools and Rock Mode

We realized late on that we had no good grasp on when the badge was connected to WIFI, and when it could reach the MQTT backend. Luckily, our libs for each had a status function, so I quickly slapped together a menu option in the vein of existing games i'd made to display these statuses to users. This was SO HELPFUL during the conference to get badges working during network outages. I'm so glad pandatrax asked me to take this on, and I'm upset we didn't have the forsight to make more/better debugging tools further in advance.

I spent the last hours of development time before the con doors opened, making Rock Mode work. Rock mode is simple: If the backend says you're a rock, then your badge client just draws a rock that rolls around, instead of a CyberPartner progressing through its' life stages. Rock mode was meant to troll one specific person, and I hope they felt the love.

## Badge Launch Day

### Updating firmware, de/reregistering iButtons, preserving linecon in the HHV

In the spirit of basically every volunteer project, we tested everything in production, including our mass-flashing solution. I knew the linecon was real when not one, but two unique bigbrains walked up to offer their services to optimize our flashing process, including but not limited to:

1. Rewriting (or just writing anew) our mass-flashing solution which looks for new USB devices being plugged into a hub, and tries to throw firmware at it
2. Optimizing our existing build pipeline with new flags using SPI at super speeds

In the end, I don't feel bad that there was an atrocious line at a hacker con for ~a day. Linecon is **THE EASIEST** opportunity to make a friend by bemoaning about the one thing everybody hates: waiting in line. It's an essential part of the con experience, no one should escape it.

We had another fun issue pop up with the iButtons where if the badge registered an iButton but networking was not working for watever reason (there were a few), then the badge would work fine but the user couldn't register for the discord bot which provides updates over chat about your current progress. To fix this, we had to enter the su password, which gave some users a free achievement and also possibly exposed our hard password to the masses via shoulder surfing. **Next time,** we'll make debugging and troubleshooting commands accessible through a less privileged interface which DOES NOT yield an achievement.

### Hackers Hacking

We made a little oopsie with our network security between the badge and the backend, TLS ended up getting disabled on the MQTT connections. Attendees were able to extract the badge's wifi network credentials from the firmware?, and set up a bridge on the edge of the parking lot to begin AitM'ing network traffic on Saturday night. This lead to several people publishing scripts to publish tampered data to the MQTT backend. For more on this, see the [cackalackybadgyfirmware2025](https://github.com/lockfale/cackalackybadgyfirmware2025) public repository.

I had to go night night by this point, so I'm not 100% on the details.

## Closing Thoughts

The team got a lot of really positive feedback on the badge overall, but there was definitely a vocal minority who wanted a cute cuddly virtual pet to nuture. The anti-game features of this badge were definitely lost on those with laser focus on achieving old-age for their CyberPartner. After all, this hardware is meant to entertain you for less than 3 days while you're distacted with a hundred other things. It's just a badge :P

I hope after suffering through these notes from the badge flashing and firmware desk, you've gained confidence to pick up some cheap embedded hardware and start mucking around with it. There's a lot of work especially if you're doing it all yourself, but it's fun, it's not too hard, and there's a ton of examples out on the internet to lift ideas and inspiration from.

### More Thanks

- My wife, for dealing with all my chatter, ranting, and raving about some dumb project I'm hot on. For the late nights I could've been on the couch not staring at my laptop. I love you!
- [melvin2001](https://github.com/melvin2001) For the invite, for the dev hardware, for running lead on this whole project year after year. For handling the tariffs and everything that followed when it came for the badge in the middle of the night.
- [pandatrax](https://github.com/pandatrax) For dealing with my incessant questions, sharing so many great examples, letting me crash your room, and just generally being a rad collaborator. You raised the standard on so many things for this badge, you gave us the deathButton, and I'm grateful for you.
- [persianc](https://github.com/persinac) For dealing with my last minute achievement woes, for doing great IR when shit hit the fan, for just being an easy person to be near.
- [Clarke Hackworth](https://github.com/clarkehackworth), the mother Jeff, author and iterator of finer games than I could make. A true inspiration.
- [s0lray](https://github.com/s0lray) + Mairebear for the therapy session

Until next year, I leave you with my favorite con decoration

![The Legend](/assets/images/2025/05/cackalackybadgy-2025/notorious.jpg)

## Related Content

- [Alex's Backend writeup](https://medium.com/@persinac/c-ck-l-cky-con-2025-d-day-technical-retro-4c445f3e2a3d)
- [cackalackybadgyfirmware2025](https://github.com/lockfale/cackalackybadgyfirmware2025): The public repo we'll move the firmware to after cleanup
- the [CyberPartner Instruction Manual](https://github.com/lockfale/cackalackybadgyfirmware2025/blob/main/media/cyberpartner_manual_v1.pdf)
- [DS1971 Data Sheet](https://www.analog.com/media/en/technical-documentation/data-sheets/DS1971.pdf)
- [DS2430A Data Sheet](https://www.analog.com/media/en/technical-documentation/data-sheets/DS2430A.pdf)
- [DS9092 Data Sheet](https://www.analog.com/media/en/technical-documentation/data-sheets/DS9092-DS9092T.pdf)
- [image2cpp](http://javl.github.io/image2cpp/)
- [make8bitart](https://make8bitart.com/)
- [SSD1306 Data Sheet](https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf)
- [LIS2DW12 Data Sheet](https://www.st.com/resource/en/datasheet/lis2dw12.pdf)
