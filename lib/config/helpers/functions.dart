String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text; // Si la cadena está vacía, simplemente retorna la cadena
  }
  return text[0].toUpperCase() + text.substring(1); // Capitaliza la primera letra y concatena el resto
}