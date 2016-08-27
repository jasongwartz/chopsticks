# Road Map

## Smaller Ideas for Current Version

There are several small enhancements that can be made to the current version of the application, and some larger features that are planned for future versions.

- An extensive help menu, tooltip on mouseover, or first-run guide
- Graphic design by a qualified UI designer
- Greater library of samples, which also necessitates a redesigned sample tray
- Ability to add custom samples or song snippets from a user's local machine
- A visual indication (light flash, for example) when a given sample is playing

## Ideas for Future Versions

### Text Notation and Input

To help bridge the knowledge gap between graphical programming in this application and text-based programming in more advanced systems like Sonic Pi or ChucK, a simple text input window would be added. If a node on the canvas has a codepath implemented with wrappers, opening the text window for that node could show an equivalent written expression. This would necessitate the design of a domain-specific language (as Sonic Pi has done), perhaps related to CoffeeScript or another easily-readable language. Futher, a user with familiarity in the domain-specific language could interact with the application more directly by typing code into the text window. This would allow a more advanced level of learning and lessen the transition between this application and other tools.

### Accessible Use

Many of the educational programming environments, like this project, use a visual environment for writing and editing the graphical code. This provides an accesibility barrier for people with vision impairments, who are especially likely to benefit from the ability to learn about coding through music. The educational potential for a music-based system to teach programming to those with vision impairments is significant: a typical "Hello World!" printed on a command line is already underwhelming enough *with* the visual feedback of seeing it print in the console. There are multiple potential directions to accomodate this: a tactile system, inspired by the reacTable but with the addition of programming syntatical nodes, could be built; a system could be designed to incorporate haptic feedback, aiding the user through touch-based cues; the interaction model on a computer or mobile device could be refined to accomodate a standard screen-reading system; the interaction model could be more thoroughly redesigned so as to be usable without the aid of external devices, through built-in audio or spoken elements. These are all ambitious techniques but could have deep educational and enjoyment value.

### Offline Workflow

It can be difficult to remember in a well-connected environment, such as a university with widespread and fast Wi-Fi, that not all schools or teaching environments will be equipped with a stable internet connection. Designing this project for high availability through the web and browser provided portability benefits which could be greater increased by a native desktop port of the application. Modern tools make this a feasible prospect: Electron is an example of a toolchain which can port web applications to a desktop equivalent using an embedded Chromium browser, and Ionic provides similar functionality for mobile. These tools come with a computation cost, so the tolerances for time latency would need to continue to be evaluated.
