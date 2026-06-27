import Foundation

/// 1:1 port of `lib/data/course_files.dart`. URLs are built from
/// `AppConfig.r2Base` (Cloudflare R2 bucket) rather than inlining the host.
private enum R2 {
    static let dld = "\(AppConfig.r2Base)/dld"
    static let c2  = "\(AppConfig.r2Base)/circuits%20II"
}

let kCourseFiles: [String: [FileEntry]] = [
    "dld": [
        FileEntry(type: .reference, label: "Textbook", title: "DLD Textbook",
            desc: "Full course textbook (~26 MB) — keep it open in another tab.",
            versions: [FileVersion(label: "PDF", url: "\(R2.dld)/DLD_Textbook.pdf")]),

        FileEntry(type: .classwork, label: "Classwork", title: "Classwork 1", desc: "In-class problem set 1.",
            versions: [FileVersion(label: "PDF", url: "\(R2.dld)/ECE_3441_ClassWork1.pdf")]),
        FileEntry(type: .classwork, label: "Classwork", title: "Classwork 2", desc: "In-class problem set 2.",
            versions: [FileVersion(label: "PDF", url: "\(R2.dld)/ECE_3441_ClassWork2.pdf")]),
        FileEntry(type: .classwork, label: "Classwork", title: "Classwork 3", desc: "In-class problem set 3.",
            versions: [FileVersion(label: "PDF", url: "\(R2.dld)/ECE_3441_ClassWork3.pdf")]),
        FileEntry(type: .classwork, label: "Classwork", title: "Classwork 4", desc: "In-class problem set 4.",
            versions: [FileVersion(label: "PDF", url: "\(R2.dld)/ECE_3441_ClassWork4.pdf")]),
        FileEntry(type: .classwork, label: "Classwork", title: "Classwork 5", desc: "In-class problem set 5.",
            versions: [FileVersion(label: "PDF", url: "\(R2.dld)/ECE_3441_ClassWork5.pdf")]),

        FileEntry(type: .quiz, label: "Quiz", title: "Quiz 1", desc: "Worked solutions for quiz 1.",
            versions: [FileVersion(label: "Solutions", url: "\(R2.dld)/ECE_3441_Quiz1_Solutions.pdf")]),
        FileEntry(type: .quiz, label: "Quiz", title: "Quiz 2", desc: "Quiz 2 problem set with solutions for both variants.",
            versions: [
                FileVersion(label: "Quiz A", url: "\(R2.dld)/ECE_3441_Quiz2.pdf"),
                FileVersion(label: "Quiz B Solutions", url: "\(R2.dld)/ECE_3441_Quiz2B_Solutions.pdf"),
                FileVersion(label: "Quiz C Solutions", url: "\(R2.dld)/ECE_3441_Quiz2C_Solutions.pdf"),
            ]),
        FileEntry(type: .quiz, label: "Quiz", title: "Quiz 3", desc: "Quiz 3 with solutions, variant A solutions, and the crib sheet.",
            versions: [
                FileVersion(label: "Quiz A", url: "\(R2.dld)/ECE_3441_Quiz3.pdf"),
                FileVersion(label: "Quiz A Solutions", url: "\(R2.dld)/ECE_3441_Quiz3_Solutions.pdf"),
                FileVersion(label: "Quiz B Solutions", url: "\(R2.dld)/ECE_3441_Quiz3A_Solutions.pdf"),
                FileVersion(label: "Crib Sheet", url: "\(R2.dld)/ECE_3441_Quiz3-CribSheet.pdf"),
            ]),
        FileEntry(type: .quiz, label: "Quiz", title: "Quiz 4", desc: "Quiz 4 with solutions and the variant B set.",
            versions: [
                FileVersion(label: "Quiz A", url: "\(R2.dld)/ECE_3441_Quiz4.pdf"),
                FileVersion(label: "Quiz A Solutions", url: "\(R2.dld)/ECE_3441_Quiz4_Solutions.pdf"),
                FileVersion(label: "Quiz B", url: "\(R2.dld)/ECE_3441_Quiz4B.pdf"),
                FileVersion(label: "Quiz B Solutions", url: "\(R2.dld)/ECE_3441_Quiz4B_Solutions.pdf"),
            ]),

        FileEntry(type: .exam, label: "Exam", title: "Exam 1 — Solutions", desc: "Worked solutions for exam 1.",
            versions: [FileVersion(label: "PDF", url: "\(R2.dld)/ECE_3441_Exam1_Solutions.pdf")]),

        FileEntry(type: .homework, label: "Homework", title: "HW Problem Set", desc: "Compiled practice problem set for additional reps.",
            versions: [FileVersion(label: "PDF", url: "\(R2.dld)/HW_Problems_Set.pdf")]),
        FileEntry(type: .homework, label: "Homework", title: "DLD HW Problems", desc: "Extra DLD homework practice problems.",
            versions: [FileVersion(label: "PDF", url: "\(R2.dld)/DLD_HW_Problems.pdf")]),
    ],

    "circuits2": [
        FileEntry(type: .reference, label: "Reference", title: "Formula Sheet",
            desc: "Quick-reference formula sheet for Circuits 2.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/Formula%20Sheet.pdf")]),

        FileEntry(type: .homework, label: "Homework", title: "HW1", desc: "Spring 2026 homework 1.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_HW1.pdf")]),
        FileEntry(type: .homework, label: "Homework", title: "HW2", desc: "Spring 2026 homework 2.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_HW2.pdf")]),
        FileEntry(type: .homework, label: "Homework", title: "HW3", desc: "Spring 2026 homework 3.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_HW3.pdf")]),
        FileEntry(type: .homework, label: "Homework", title: "HW4", desc: "Spring 2026 homework 4.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_HW4.pdf")]),
        FileEntry(type: .homework, label: "Homework", title: "HW5", desc: "Spring 2026 homework 5.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_HW5.pdf")]),
        FileEntry(type: .homework, label: "Homework", title: "HW6", desc: "Spring 2026 homework 6.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_HW6.pdf")]),
        FileEntry(type: .homework, label: "Homework", title: "HW7", desc: "Spring 2026 homework 7.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_HW7.pdf")]),
        FileEntry(type: .homework, label: "Homework", title: "HW8", desc: "Spring 2026 homework 8.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_HW8.pdf")]),

        FileEntry(type: .quiz, label: "Quiz", title: "Quiz 1 — Solutions", desc: "Worked solutions for quiz 1.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_Quiz1_Solutions.pdf")]),
        FileEntry(type: .quiz, label: "Quiz", title: "Quiz 2 — Solutions", desc: "Worked solutions for quiz 2.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_Quiz2_Solutions.pdf")]),
        FileEntry(type: .quiz, label: "Quiz", title: "Quiz 3 — Solutions", desc: "Worked solutions for quiz 3.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_Quiz3_Solutions.pdf")]),
        FileEntry(type: .quiz, label: "Quiz", title: "Quiz 4 — Solutions", desc: "Worked solutions for quiz 4.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_Quiz4_Solutions.pdf")]),
        FileEntry(type: .quiz, label: "Quiz", title: "Quiz 5 — Solutions", desc: "Worked solutions for quiz 5.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_Quiz5_Solutions.pdf")]),

        FileEntry(type: .exam, label: "Exam", title: "Exam 1", desc: "First exam packet.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/Exam_1.pdf")]),
        FileEntry(type: .exam, label: "Review", title: "Exam 1 — Review", desc: "Review packet for exam 1.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_Exam1_Review.pdf")]),
        FileEntry(type: .exam, label: "Review", title: "Exam 2 — Review", desc: "Review packet for exam 2.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_Exam2_Review.pdf")]),
        FileEntry(type: .exam, label: "Review", title: "Exam 3 — Review", desc: "Review packet for exam 3.",
            versions: [FileVersion(label: "PDF", url: "\(R2.c2)/ECE2202_Exam3_Review.pdf")]),
    ],

    "cprog": [
        // Placeholder — drop new entries here once files land in the bucket.
    ],
]
