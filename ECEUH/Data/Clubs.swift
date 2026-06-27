import Foundation

/// 1:1 port of `lib/data/clubs.dart`. `iconKey` holds the original Material icon
/// name, resolved to an SF Symbol by `Club.symbolName` / `SFSymbol.forClub`.
let kClubs: [Club] = [
    Club(
        name: "IEEE UH Student Branch",
        slug: "ieee",
        description: "The largest technical professional organization on campus. "
            + "Hosts workshops, IEEE SoutheastCon prep, networking events, and "
            + "E-Days each semester. Open to all engineering majors.",
        iconKey: "electrical_services",
        tags: ["professional", "ieee", "networking"],
        meetingTime: "Tuesdays 6:00 PM",
        location: "Engineering Building 1, Room 120",
        contactEmail: "ieee@egr.uh.edu",
        instagramUrl: "https://www.instagram.com/ieeeuh",
        websiteUrl: "https://ieee.egr.uh.edu"),
    Club(
        name: "Eta Kappa Nu (HKN)",
        slug: "hkn",
        description: "IEEE's ECE honor society. Requires top-quarter standing for "
            + "juniors or top-third for seniors. Offers peer tutoring, industry "
            + "networking, and scholarship opportunities.",
        iconKey: "workspace_premium",
        tags: ["honor society", "ieee", "academic"],
        meetingTime: "Mondays 5:00 PM",
        location: "Engineering Building 1, Room 314",
        contactEmail: "hkn@egr.uh.edu",
        instagramUrl: "https://www.instagram.com/uh_hkn",
        websiteUrl: "https://hkn.egr.uh.edu"),
    Club(
        name: "UH Robotics Club",
        slug: "robotics",
        description: "Builds and competes with autonomous and semi-autonomous robots. "
            + "Competes in IEEE SoutheastCon, MATE ROV, and fire-fighting "
            + "challenges. All skill levels welcome — bring a soldering iron.",
        iconKey: "precision_manufacturing",
        tags: ["competition", "robotics", "hands-on"],
        meetingTime: "Thursdays 6:00 PM",
        location: "Engineering Building 2, Lab 220",
        instagramUrl: "https://www.instagram.com/uhroboticsclub",
        discordUrl: "https://discord.gg/uhrobotics",
        websiteUrl: "https://robotics.egr.uh.edu"),
    Club(
        name: "Society of Hispanic Professional Engineers",
        slug: "shpe",
        description: "National organization with a strong UH presence. Organizes the "
            + "SHPE National Convention trip, industry panel nights, résumé "
            + "workshops, and scholarship awareness campaigns.",
        iconKey: "groups",
        tags: ["community", "professional", "career"],
        meetingTime: "Wednesdays 6:30 PM",
        location: "Engineering Building 1, Room 102",
        contactEmail: "shpe.uh@gmail.com",
        instagramUrl: "https://www.instagram.com/shpeuh",
        websiteUrl: "https://shpe.egr.uh.edu"),
    Club(
        name: "National Society of Black Engineers",
        slug: "nsbe",
        description: "Community-driven chapter focused on academic excellence and "
            + "professional development. Coordinates the NSBE National Convention, "
            + "fall tech talks, and mentorship matching for ECE students.",
        iconKey: "groups",
        tags: ["community", "professional", "career"],
        meetingTime: "Thursdays 5:30 PM",
        location: "Engineering Building 1, Room 116",
        contactEmail: "nsbeuh@gmail.com",
        instagramUrl: "https://www.instagram.com/uhnsbe",
        websiteUrl: "https://nsbe.egr.uh.edu"),
    Club(
        name: "IEEE Women in Engineering",
        slug: "wie",
        description: "UH's IEEE WIE affinity group. Runs panel series with female "
            + "engineers from industry, connects underclassmen with graduate "
            + "student mentors, and co-hosts social events with neighboring chapters.",
        iconKey: "people_alt",
        tags: ["community", "women", "ieee"],
        meetingTime: "Biweekly Wednesdays 5:00 PM",
        location: "Engineering Building 1, Room 208",
        contactEmail: "wie.uh@gmail.com",
        instagramUrl: "https://www.instagram.com/ieee_wie_uh"),
    Club(
        name: "Tau Beta Pi",
        slug: "tbp",
        description: "The oldest engineering honor society in the US. Texas Gamma chapter "
            + "recognizes top students across all engineering disciplines and hosts "
            + "community service projects and leadership programs.",
        iconKey: "star_outline",
        tags: ["honor society", "academic", "all-engineering"],
        meetingTime: "First Monday of each month, 5:30 PM",
        location: "Engineering Building 2, Room 114",
        contactEmail: "tbp.uh@gmail.com",
        instagramUrl: "https://www.instagram.com/tbp_uh_texgamma",
        websiteUrl: "https://tbp.egr.uh.edu"),
    Club(
        name: "UH ACM Student Chapter",
        slug: "acm",
        description: "The computing counterpart to IEEE. Runs a competitive programming "
            + "team (ICPC), hosts Hackathon UH, and weekly LeetCode problem "
            + "sessions — directly relevant to CS-adjacent ECE tracks.",
        iconKey: "code",
        tags: ["software", "competition", "cs"],
        meetingTime: "Mondays 6:00 PM",
        location: "Philip Guthrie Hoffman Hall, Room 232",
        instagramUrl: "https://www.instagram.com/uhacm",
        discordUrl: "https://discord.gg/uhacm",
        websiteUrl: "https://acm.cs.uh.edu"),
]

func clubBySlug(_ slug: String) -> Club? {
    kClubs.first { $0.slug == slug }
}
