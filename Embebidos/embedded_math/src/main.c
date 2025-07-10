#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define SIN_LENGTH ((int)360)
#define COS_LENGTH ((int)360)
#define FILE_NAME "math_tables.txt"
#define PI 3.14159265358979323846

int main(void)
{
  FILE *tablesFile;
  int i;

  tablesFile = fopen(FILE_NAME, "w");

  if (tablesFile == NULL)
  {
    printf("ERROR: no se pudo abrir el archivo. '%s'", FILE_NAME);
    exit(1);
  }

  fprintf(tablesFile, "const float sin_table[%d] = {\n", SIN_LENGTH+1);
  for (i = 0; i < SIN_LENGTH-1; i++)
  {
    fprintf(tablesFile, "%.5ff, ", sin(i*PI/90));
  }
  fprintf(tablesFile, "%.5ff\n};", sin(SIN_LENGTH*PI/90));

  fprintf(tablesFile, "\n\n\n");

  fprintf(tablesFile, "const float cos_table[%d] = {", COS_LENGTH+1);
  for (i = 0; i < COS_LENGTH; i++)
  {
    fprintf(tablesFile, "%.5ff, ", cos(i*PI/90));
  }
  fprintf(tablesFile, "%.5ff\n};\n\n", cos(COS_LENGTH*PI/90));

  fclose(tablesFile);

  return 0;
}
