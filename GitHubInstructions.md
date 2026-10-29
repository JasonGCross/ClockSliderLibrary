# Instructions for GitHub

There are two different repos for this workspace

```text
clock_slider_control/            <- repo root
├── ClockSliderLibrary/          <- subtree
│   ├── Package.swift            
│   ├── Sources/ClockSliderLibrary/...
│   └── Tests/ClockSliderLibraryTests/...
├── ClockSliderLibraryClientMac/
├── ClockSliderLibraryClientiOS/
└── ...
```

Whenever the code is changed inside the library, push it to its own repo like this:

```shell
git subtree split --prefix=ClockSliderLibrary -b library-only
git push <NEW_REPO_URL> library-only:main
```

## History
The Library used to be the only repo. Then there were two sibling repos that existed:

1. [ClockSliderLibraryClientMac](https://github.com/JasonGCross/ClockSliderLibraryClientMac)
2. [ClockSliderLibraryClientiOS](https://github.com/JasonGCross/ClockSliderLibraryClientiOS)

At some point (around 2025), the three repos (shared library, Mac, iOS) used Git sub-modules. Then they were combined into a single workspace, and the sub-modules abandonded. Then in October 2026 the library was pulled out into its own separate repo. The motivation for this is to allow other applications to access the library as an indivdual Swift package, with the package manifest in the expected location (the top level).

```text
ClockSliderLibrary/    <- repo root 
├── Package.swift            
├── Sources/ClockSliderLibrary/...
└── Tests/ClockSliderLibraryTests/...
```
