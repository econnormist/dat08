// MIDI monitor: logs everything a MIDI device (default: "Dato") sends, one message per line.
// Clock ticks (0xF8) are summarized once per second instead of printed.
// Usage: swift tools/midimon.swift [name-filter]
import CoreMIDI
import Foundation

setvbuf(stdout, nil, _IOLBF, 0)
let filter = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "dato"
let t0 = Date()
var clockCount = 0

func name(_ e: MIDIEndpointRef) -> String {
  var s: Unmanaged<CFString>?
  MIDIObjectGetStringProperty(e, kMIDIPropertyDisplayName, &s)
  return (s?.takeRetainedValue() as String?) ?? "?"
}
let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
func noteName(_ n: UInt8) -> String { "\(noteNames[Int(n) % 12])\(Int(n) / 12 - 1)" }

func describe(_ b: [UInt8]) -> String? {
  guard let st = b.first else { return nil }
  let hex = b.map { String(format: "%02X", $0) }.joined(separator: " ")
  let ch = Int(st & 0x0F) + 1
  var what: String
  switch st {
  case 0xF8: clockCount += 1; return nil
  case 0xFA: what = "START"
  case 0xFB: what = "CONTINUE"
  case 0xFC: what = "STOP"
  case 0xFE: return nil // active sensing
  case 0xF0: what = "SYSEX (\(b.count) bytes)"
  case 0xF2: what = "SONG POSITION \(b.count > 2 ? Int(b[1]) | Int(b[2]) << 7 : 0)"
  default:
    switch st & 0xF0 {
    case 0x90 where b.count > 2 && b[2] > 0: what = "NOTE ON  ch\(ch) note \(b[1]) (\(noteName(b[1]))) vel \(b[2])"
    case 0x90, 0x80: what = "note off ch\(ch) note \(b.count > 1 ? b[1] : 0)"
    case 0xB0: what = "CC       ch\(ch) cc \(b[1]) = \(b.count > 2 ? b[2] : 0)"
    case 0xC0: what = "PROGRAM  ch\(ch) \(b[1])"
    case 0xE0: what = "PITCHBEND ch\(ch) \(b.count > 2 ? (Int(b[1]) | Int(b[2]) << 7) - 8192 : 0)"
    case 0xD0: what = "AFTERTOUCH ch\(ch) \(b[1])"
    case 0xA0: what = "POLY AT  ch\(ch) note \(b[1]) = \(b.count > 2 ? b[2] : 0)"
    default: what = "OTHER"
    }
  }
  return String(format: "%8.3f  ", Date().timeIntervalSince(t0)) + what.padding(toLength: 44, withPad: " ", startingAt: 0) + " [\(hex)]"
}

// split a raw byte stream into MIDI messages
func messages(_ bytes: [UInt8]) -> [[UInt8]] {
  var out: [[UInt8]] = [], i = 0
  while i < bytes.count {
    let st = bytes[i]
    if st == 0xF0 { var j = i; while j < bytes.count && bytes[j] != 0xF7 { j += 1 }; out.append(Array(bytes[i...min(j, bytes.count - 1)])); i = j + 1; continue }
    if st >= 0xF8 { out.append([st]); i += 1; continue }
    let len: Int
    switch st & 0xF0 { case 0xC0, 0xD0: len = 2; case 0xF0: len = st == 0xF2 ? 3 : (st == 0xF3 || st == 0xF1 ? 2 : 1); default: len = 3 }
    out.append(Array(bytes[i..<min(i + len, bytes.count)])); i += len
  }
  return out
}

var client = MIDIClientRef(), port = MIDIPortRef()
MIDIClientCreate("midimon" as CFString, nil, nil, &client)
MIDIInputPortCreateWithBlock(client, "in" as CFString, &port) { list, _ in
  var p = list.pointee.packet
  for _ in 0..<list.pointee.numPackets {
    let bytes = withUnsafeBytes(of: p.data) { Array($0.prefix(Int(p.length))) }
    for m in messages(bytes) { if let line = describe(m) { print(line) } }
    p = MIDIPacketNext(&p).pointee
  }
}
var found = false
for i in 0..<MIDIGetNumberOfSources() {
  let src = MIDIGetSource(i)
  if name(src).lowercased().contains(filter.lowercased()) {
    MIDIPortConnectSource(port, src, nil); print("Listening to: \(name(src))"); found = true
  }
}
if !found { print("No MIDI source matching \"\(filter)\""); exit(1) }

var lastClock = 0
Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
  if clockCount != lastClock {
    let perSec = clockCount - lastClock
    print(String(format: "%8.3f  ", Date().timeIntervalSince(t0)) + "(clock: \(perSec) ticks/s ≈ \(String(format: "%.1f", Double(perSec) * 60 / 24)) BPM)")
    lastClock = clockCount
  }
}
RunLoop.main.run()
