import Foundation

/// 1:1 port of `lib/data/professors.dart`. Drives the Faculty screen and the
/// home-screen faculty spotlight.
let kProfessorCourses: [ProfessorCourse] = [
    ProfessorCourse(id: "engi1100", code: "ENGI 1100", title: "Introduction to Engineering", profs: [
        Professor(name: "Dr. Alexandra Landon", shortName: "Landon", initials: "AL", dept: "Engineering Dept.",
            overall: 4.67, difficulty: 2.0, wouldTake: 100, rmpUrl: "https://www.ratemyprofessors.com/professor/2880955"),
        Professor(name: "Dr. Matthew Zelisko", shortName: "Zelisko", initials: "MZ", dept: "Engineering Dept.",
            overall: 4.33, difficulty: 2.56, wouldTake: 86, rmpUrl: "https://www.ratemyprofessors.com/professor/2155783"),
    ]),
    ProfessorCourse(id: "engi1331", code: "ENGI 1331", title: "Computing for Engineers", profs: [
        Professor(name: "Dr. Alexandra Landon", shortName: "Landon", initials: "AL", dept: "Engineering Dept.",
            overall: 4.78, difficulty: 2.22, wouldTake: 100, rmpUrl: "https://www.ratemyprofessors.com/professor/2880955"),
        Professor(name: "Dr. Matthew Zelisko", shortName: "Zelisko", initials: "MZ", dept: "Engineering Dept.",
            overall: 4.13, difficulty: 3.2, wouldTake: 86, rmpUrl: "https://www.ratemyprofessors.com/professor/2155783"),
    ]),
    ProfessorCourse(id: "engi2304", code: "ENGI 2304", title: "Technical Communications", profs: [
        Professor(name: "Dr. Chad Wilson", shortName: "Wilson", initials: "CW", dept: "Engineering Dept.",
            overall: 4.6, difficulty: 2.8, wouldTake: 92, rmpUrl: "https://www.ratemyprofessors.com/professor/729504"),
        Professor(name: "Dr. Carl Estrada", shortName: "Estrada", initials: "CE", dept: "Engineering Dept.",
            overall: 1.5, difficulty: 4.5, wouldTake: 0, rmpUrl: "https://www.ratemyprofessors.com/professor/2827301"),
        Professor(name: "Dr. Jennifer Ettelson", shortName: "Ettelson", initials: "JE", dept: "Engineering Dept.",
            rmpUrl: "https://www.ratemyprofessors.com/professor/3141994"),
        Professor(name: "Dr. Deborah Salvon", shortName: "Salvon", initials: "DS", dept: "Engineering Dept.",
            overall: 4.44, difficulty: 1.56, wouldTake: 84, rmpUrl: "https://www.ratemyprofessors.com/professor/1445737"),
    ]),
    ProfessorCourse(id: "ece2201", code: "ECE 2201", title: "Circuits Analysis I", profs: [
        Professor(name: "Dr. Chu Meh Chu", shortName: "Chu", initials: "CC", dept: "Electrical Engineering Dept.",
            overall: 1.8, difficulty: 4.2, wouldTake: 40, rmpUrl: "https://www.ratemyprofessors.com/professor/3074605"),
        Professor(name: "Dr. Paul Ruchhoeft", shortName: "Ruchhoeft", initials: "PR", dept: "Electrical Engineering Dept.",
            overall: 5.0, difficulty: 3.5, wouldTake: 72, rmpUrl: "https://www.ratemyprofessors.com/professor/1286292"),
        Professor(name: "Dr. Deepa Ramachandran", shortName: "Ramachandran", initials: "DR", dept: "Electrical Engineering Dept.",
            overall: 4.5, difficulty: 3.0, wouldTake: 100, rmpUrl: "https://www.ratemyprofessors.com/professor/2729114"),
        Professor(name: "Dr. Dave Shattuck", shortName: "Shattuck", initials: "DS", dept: "Electrical Engineering Dept.",
            overall: 4.5, difficulty: 4.25, wouldTake: 71, rmpUrl: "https://www.ratemyprofessors.com/professor/238536"),
    ]),
    ProfessorCourse(id: "circuits2", code: "ECE 2202", title: "Circuit Analysis II", profs: [
        Professor(name: "Dr. Xiaonan Shan", shortName: "Shan", initials: "XS", dept: "Electrical Engineering Dept.",
            overall: 4.5, difficulty: 3.5, wouldTake: 100, rmpUrl: "https://www.ratemyprofessors.com/professor/2991318"),
        Professor(name: "Dr. Deepa Ramachandran", shortName: "Ramachandran", initials: "DR", dept: "Electrical Engineering Dept."),
        Professor(name: "Dr. Dave Shattuck", shortName: "Shattuck", initials: "DS", dept: "Electrical Engineering Dept.",
            overall: 4.13, difficulty: 4.31, wouldTake: 71, rmpUrl: "https://www.ratemyprofessors.com/professor/238536"),
    ]),
    ProfessorCourse(id: "ece2100", code: "ECE 2100", title: "Circuit Analysis Lab", profs: [
        Professor(name: "Prof. Name", shortName: "TBD", initials: "??", dept: "Electrical Engineering Dept."),
    ]),
    ProfessorCourse(id: "inde2333", code: "INDE 2333", title: "Engineering Statistics", profs: [
        Professor(name: "Dr. Yaping Wang", shortName: "Wang", initials: "YW", dept: "Industrial Engineering Dept.",
            overall: 3.71, difficulty: 2.57, wouldTake: 87, rmpUrl: "https://www.ratemyprofessors.com/professor/2175000"),
        Professor(name: "Dr. Nirathi Keerthi Govindu", shortName: "Govindu", initials: "NG", dept: "Industrial Engineering Dept.",
            overall: 2.5, difficulty: 2.5, wouldTake: 34, rmpUrl: "https://www.ratemyprofessors.com/professor/2926063"),
        Professor(name: "Dr. May Feng", shortName: "Feng", initials: "MF", dept: "Industrial Engineering Dept.",
            overall: 4.63, difficulty: 2.25, wouldTake: 77, rmpUrl: "https://www.ratemyprofessors.com/professor/2143005"),
        Professor(name: "Dr. Nate Wiggins", shortName: "Wiggins", initials: "NW", dept: "Industrial Engineering Dept.",
            rmpUrl: "https://www.ratemyprofessors.com/professor/2831279"),
    ]),
    ProfessorCourse(id: "cprog", code: "ECE 3331", title: "Programming Applications in ECE", profs: [
        Professor(name: "Dr. Biresh Kumar Joardar", shortName: "Joardar", initials: "BJ", dept: "Electrical Engineering Dept.",
            overall: 5.0, difficulty: 2.0, wouldTake: 100, rmpUrl: "https://www.ratemyprofessors.com/professor/2894356"),
        Professor(name: "Dr. Bhavin R. Sheth", shortName: "Sheth", initials: "BS", dept: "Electrical Engineering Dept.",
            overall: 1.5, difficulty: 4.0, wouldTake: 12, rmpUrl: "https://www.ratemyprofessors.com/professor/1585968"),
        Professor(name: "Dr. Harry Le", shortName: "Le", initials: "HL", dept: "Electrical Engineering Dept.",
            overall: 3.67, difficulty: 1.67, wouldTake: 38, rmpUrl: "https://www.ratemyprofessors.com/professor/2480417"),
        Professor(name: "Dr. Chu Meh Chu", shortName: "Chu", initials: "CC", dept: "Electrical Engineering Dept.",
            overall: 1.8, rmpUrl: "https://www.ratemyprofessors.com/professor/3074605"),
    ]),
    ProfessorCourse(id: "dld", code: "ECE 3441", title: "Digital Logic Design", profs: [
        Professor(name: "Dr. Bhavin R. Sheth", shortName: "Sheth", initials: "BS", dept: "Electrical Engineering Dept.",
            overall: 3.0, difficulty: 4.0, wouldTake: 70, rmpUrl: "https://www.ratemyprofessors.com/professor/1585968"),
        Professor(name: "Dr. Deepa Ramachandran", shortName: "Ramachandran", initials: "DR", dept: "Electrical Engineering Dept.",
            overall: 4.5, difficulty: 2.8, wouldTake: 100, rmpUrl: "https://www.ratemyprofessors.com/professor/2729114"),
        Professor(name: "Dr. Padmavati Viswanath", shortName: "Viswanath", initials: "PV", dept: "Electrical Engineering Dept.",
            rmpUrl: "https://www.ratemyprofessors.com/professor/3000524"),
        Professor(name: "Dr. Yufang Sun", shortName: "Sun", initials: "YS", dept: "Electrical Engineering Dept.",
            rmpUrl: "https://www.ratemyprofessors.com/professor/3163565"),
    ]),
]
