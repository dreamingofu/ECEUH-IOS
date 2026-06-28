import Foundation

/// 1:1 port of `lib/data/courses.dart`. Drives the home active-coursework
/// picker, the archives catalog, and the in-app search index.
let kCourses: [Course] = [
    // ── 1000-level ─────────────────────────────────────────────────────
    Course(slug: "engi1100", code: "ENGI 1100", title: "Introduction to Engineering",
        desc: "ENGI 1100 · Year 1 fundamentals.",
        level: 1000, units: 4,
        art: "https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=900&q=80&auto=format&fit=crop",
        isLive: false),
    Course(slug: "engi1331", code: "ENGI 1331", title: "Computing for Engineers",
        desc: "ENGI 1331 · MATLAB and problem solving.",
        level: 1000, units: 6,
        art: "matlab.webp",
        isLive: false),

    // ── 2000-level ─────────────────────────────────────────────────────
    Course(slug: "engi2304", code: "ENGI 2304", title: "Technical Communications",
        desc: "ENGI 2304 · Engineering writing and reports.",
        level: 2000, units: 4,
        art: "https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=900&q=80&auto=format&fit=crop",
        isLive: false),
    Course(slug: "ece2201", code: "ECE 2201", title: "Circuit Analysis I",
        archiveTitle: "Circuits Analysis I",
        desc: "ECE 2201 · DC circuits, KVL, KCL, Thevenin.",
        level: 2000, units: 8,
        art: "https://images.unsplash.com/photo-1597852074816-d933c7d2b988?w=900&q=80&auto=format&fit=crop",
        isLive: false),
    Course(slug: "circuits2", code: "ECE 2202", title: "Circuit Analysis II",
        desc: "ECE 2202 · AC analysis, phasors, and RLC.",
        level: 2000, units: 8,
        art: "circuits2.webp",
        isLive: true,
        hub: CourseHub(routeName: "course", kicker: "Course Hub",
            title: "Circuits 2",
            desc: "A cleaner front door for the second circuits course: unit navigation, downloadable bucket files, and outside references each get their own destination page."),
        sections: CourseSections(
            files: SectionRef(title: "File Library",
                desc: "The R2-backed Circuits 2 documents now live in a proper library page instead of being scattered across a mixed-purpose resource grid."),
            links: SectionRef(title: "External Resources",
                desc: "Circuit tools and trusted references get their own page so the landing page stays consistent with DLD and C programming."))),
    Course(slug: "ece2100", code: "ECE 2100", title: "Circuit Analysis Lab",
        desc: "ECE 2100 · Practical circuit building and testing.",
        level: 2000, units: 2,
        art: "https://images.unsplash.com/photo-1581090700227-1e37b190418e?w=900&q=80&auto=format&fit=crop",
        isLive: false),
    Course(slug: "inde2333", code: "INDE 2333", title: "Engineering Statistics",
        desc: "INDE 2333 · Probability and data analysis.",
        level: 2000, units: 6,
        art: "https://images.unsplash.com/photo-1543286386-713bdd548da4?w=900&q=80&auto=format&fit=crop",
        isLive: false),

    // ── 3000-level ─────────────────────────────────────────────────────
    Course(slug: "cprog", code: "ECE 3331", title: "Programming Applications in ECE",
        desc: "ECE 3331 · Pointers, memory, structs, algorithms.",
        level: 3000, units: 8,
        art: "cprog.webp",
        isLive: true,
        hub: CourseHub(routeName: "course", kicker: "Course Hub",
            title: "Programming with C",
            desc: "The C course now follows the same clean structure as the rest of the site: one hub, three consistent cards, and dedicated pages for the real content."),
        sections: CourseSections(
            files: SectionRef(title: "File Library",
                desc: "Keep the file library visually aligned with the DLD page while giving the C course its own destination for quizzes, exams, and references."),
            links: SectionRef(title: "External Resources",
                desc: "Curated references for C syntax, compiler behavior, debugging, and memory tools get a proper destination page instead of a tiny block on the course page."))),
    Course(slug: "dld", code: "ECE 3441", title: "Digital Logic Design",
        desc: "ECE 3441 · K-maps, FSMs, and sequential logic.",
        level: 3000, units: 6,
        art: "dld.webp",
        isLive: true,
        hub: CourseHub(routeName: "course", kicker: "Course Hub",
            title: "Digital Logic Design",
            desc: "One consistent entry point for the full DLD workflow: topic maps, bucket-backed handouts, and the outside references that help the course click."),
        sections: CourseSections(
            files: SectionRef(title: "File Library",
                desc: "Reach the live R2-backed classwork, review sets, and reference docs from one dedicated page with a softer, consistent card treatment."),
            links: SectionRef(title: "External Resources",
                desc: "Jump from the course into the best supporting simulators, explainers, and digital-logic references without mixing them into the landing page itself."))),
    Course(slug: "ece3155", code: "ECE 3155", title: "Electronics Lab",
        desc: "ECE 3155 · Diode and BJT circuit labs.", level: 3000, units: 2,
        art: "https://images.unsplash.com/photo-1581092580497-e0d23cbdf1dc?w=900&q=80&auto=format&fit=crop",
        isLive: false),
    Course(slug: "ece3355", code: "ECE 3355", title: "Electronics",
        desc: "ECE 3355 · Diodes, BJTs, MOSFETs, and amps.", level: 3000, units: 6,
        art: "https://images.unsplash.com/photo-1518770660439-4636190af475?w=900&q=80&auto=format&fit=crop",
        isLive: false),
    Course(slug: "ece3337", code: "ECE 3337", title: "Signals & Systems Analysis",
        desc: "ECE 3337 · Fourier, Laplace, and Z-transforms.", level: 3000, units: 6,
        art: "https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=900&q=80&auto=format&fit=crop",
        isLive: false),
    Course(slug: "ece3317", code: "ECE 3317", title: "Applied EM Waves",
        desc: "ECE 3317 · Maxwells equations and transmission lines.", level: 3000, units: 6,
        art: "https://images.unsplash.com/photo-1497436072909-60f360e1d4b1?w=900&q=80&auto=format&fit=crop",
        isLive: false),
    Course(slug: "ece3436", code: "ECE 3436", title: "Microprocessor Systems",
        desc: "ECE 3436 · Assembly, memory, and microcontrollers.", level: 3000, units: 8,
        art: "https://images.unsplash.com/photo-1591488320449-011701bb6704?w=900&q=80&auto=format&fit=crop",
        isLive: false),
    Course(slug: "ece3340", code: "ECE 3340", title: "Numerical Methods",
        desc: "ECE 3340 · Algorithms for solving engineering problems.", level: 3000, units: 6,
        art: "https://images.unsplash.com/photo-1509228468518-180dd4864904?w=900&q=80&auto=format&fit=crop",
        isLive: false),
]

func courseBySlug(_ slug: String) -> Course? {
    kCourses.first { $0.slug == slug }
}

var liveCourses: [Course] { kCourses.filter { $0.isLive } }
var upcomingCourses: [Course] { kCourses.filter { !$0.isLive } }

/// True once a course has actual class data — files (homework / quizzes / exams).
func courseHasContent(_ course: Course) -> Bool {
    !(kCourseFiles[course.slug] ?? []).isEmpty
}

/// Courses with class data — the ones surfaced on Home and Archives. Empty
/// courses stay in `kCourses` (in code) and appear here automatically once files
/// are added under their slug, so classes can be rolled out as content lands.
var coursesWithContent: [Course] { kCourses.filter(courseHasContent) }
