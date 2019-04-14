double lerp(num a, num b, double t) {
  return (1 - t) * a.toDouble() + t * b.toDouble();
}