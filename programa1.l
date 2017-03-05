/*
Programa 1:
Elaborar un analizador léxico en flex o C que reconozca los componentes léxicos pertenecientes a 
las clases abajo descritas y que son del lenguaje Pascal—acordadas en clase.

modificado 20 Sep 2016
por Jose Angel Lopez Mondragon
*/

%{
/*Se incluyen librerias*/
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
/*Se definen variables globales para archivo, contadores de usos multiples y usos especificos*/
FILE *archSal;
int clase; 
int contador_p_ident, contador_p_ca = 0,posicion, flag=0, flag1=0;
char cposicion[3],ccontador_p_ca[3],ccontador_p_ident[3],cclase[3];
/*Estructura de tablas dinamicas, se usan para identificadores, cadenas, tokens*/
typedef struct tabla_g{
 char dato[10];
 struct tabla_g *siguiente;
} n_tabla;
typedef n_tabla *elemento;
typedef n_tabla *lista_e;
/*Creando tablas*/
/*tabla de identificadores*/
lista_e lista_ident = NULL;
lista_e lista_posident = NULL;
/*tabla de cadena*/
lista_e lista_ca = NULL;
lista_e lista_posca = NULL;
/*tabla de clases*/
lista_e lista_clases = NULL;
/*tabla de posiciones*/
lista_e lista_valor = NULL;
/*Estructura de tablas estaticas se usan para tablas con simbolos definidos por ejemplo tabla de palabras reservadas*/
/*pr = palabras reservadas*/
struct tablapr {
	char palabra[10];
} pr[20];
/*tde = tipos de datos estandar*/
struct tablatde {
	char palabra[10];
} tde[5];
/*fe = funciones estandar*/
struct tablafe {
	char palabra[10];
} fe[11];
/*pe = procedimiento estandar*/
struct tablape {
	char palabra[10];
} pe[6];
/*or = operadores relacionales*/
struct tablaor {
	char palabra[10];
} or[6];
/*oa = operadores asignacion*/
char oa[3];

%} 

/*Digitos 0 - 9*/
dig [0-9]
/*Letras a - z*/
char [a-zA-Z]
/*[0]Palabras reservadas*/
preservadas AND|ARRAY|BEGIN|DIV|DO|DOWNTO|ELSE|END|FOR|IF|MOD|NOT|OR|PROGRAM|REPEAT|THEN
/*[1]Identidicadores definidos por el usuario*/
ident {char}({char}|{dig})*
/*[2]Tipos de datos estandar*/
tdatos boolean|char|int|real|text
/*[3]Funciones estandar*/
festandar abs|chr|cos|eof|eoln|exp|ln|sin|sqr|sqrt|trunc
/*[4]Procedimientos estandar*/
pestandar get|put|read|readln|write|writeln
/*[5]Operadores aritmeticos*/
oparit [+\-*/]
/*[6]Operadores relacionales*/
oprela <|<=|=|<>|>|>=
/*[7]Simbolos especiales*/
simesp [,;:.()\[\]]
/*[8]Constantes enteras*/
cteint {dig}+
/*[9]Constantes reales*/
ctereal {cteint}+(\.)({dig})+
/*[10]Cadenas*/
cadena (').*(')
/*[11]Operador de asignacion*/
opasig :=
/*Comentarios*/
coment (\*).*(\*) 

%%

{tdatos} return 2;
{festandar} return 3;
{pestandar} return 4;
{preservadas} return 0;
{ident} return 1;
{oparit} return 5;
{oprela} return 6;
{simesp} return 7;
{cteint} return 8;
{ctereal} return 9;
{cadena} return 10;
{opasig} return 11;
{coment} 
 
%% 

/*-------------------------------------------------Funciones----------------------------------------------------------------*/
/*Funcion que carga a todas las tablas estaticas con sus valores correspondientes*/
void tablas(){

	strcpy(pr[0].palabra,"AND");
	strcpy(pr[1].palabra,"ARRAY");
	strcpy(pr[2].palabra,"BEGIN");
	strcpy(pr[3].palabra,"DIV");
	strcpy(pr[4].palabra,"DO");
	strcpy(pr[5].palabra,"DOWNTO");
	strcpy(pr[6].palabra,"ELSE");
	strcpy(pr[7].palabra,"END");
	strcpy(pr[8].palabra,"FOR");
	strcpy(pr[9].palabra,"IF");
	strcpy(pr[10].palabra,"MOD");
	strcpy(pr[11].palabra,"NOT");
	strcpy(pr[12].palabra,"OR");
	strcpy(pr[13].palabra,"PROGRAM");
	strcpy(pr[14].palabra,"REPEAT");
	strcpy(pr[15].palabra,"THEN");
	strcpy(pr[16].palabra,"TO");
	strcpy(pr[17].palabra,"UNTIL");
	strcpy(pr[18].palabra,"VAR");
	strcpy(pr[19].palabra,"WHILE");

	strcpy(tde[0].palabra,"boolean");
	strcpy(tde[1].palabra,"char");
	strcpy(tde[2].palabra,"integer");
	strcpy(tde[3].palabra,"real");
	strcpy(tde[4].palabra,"text");

	strcpy(fe[0].palabra,"abs");
	strcpy(fe[1].palabra,"chr");
	strcpy(fe[2].palabra,"cos");
	strcpy(fe[3].palabra,"eof");
	strcpy(fe[4].palabra,"eoln");
	strcpy(fe[5].palabra,"exp");
	strcpy(fe[6].palabra,"ln");
	strcpy(fe[7].palabra,"sin");
	strcpy(fe[8].palabra,"sqr");
	strcpy(fe[9].palabra,"sqrt");
	strcpy(fe[10].palabra,"trunc");

	strcpy(pe[0].palabra,"get");
	strcpy(pe[1].palabra,"put");
	strcpy(pe[2].palabra,"read");
	strcpy(pe[3].palabra,"readln");
	strcpy(pe[4].palabra,"write");
	strcpy(pe[5].palabra,"writeln");

	strcpy(or[0].palabra,"<");
	strcpy(or[1].palabra,"<=");
	strcpy(or[2].palabra,"=");
	strcpy(or[3].palabra,"<>");
	strcpy(or[4].palabra,">");
	strcpy(or[5].palabra,">=");

	strcpy(oa,":=");
}
/*Funcion para crear elementos, regresa el elemento creado*/
elemento crea_elemento(char valor[10]){
 elemento nuevo_elemento = (elemento)malloc(sizeof(n_tabla));
 if (nuevo_elemento != NULL){
    	strcpy(nuevo_elemento->dato, valor);
    	nuevo_elemento->siguiente = NULL;
    }
 return nuevo_elemento;
}
/*Funcion para insertar elemento en lista: recibe lista, NULL = insertar al principio, valor del elemento*/
void insertar(lista_e *lista, elemento element, char valor[10]){
 elemento nuevo_elemento = crea_elemento(valor);
 if (element != NULL){
     nuevo_elemento->siguiente = element->siguiente;
     element->siguiente = nuevo_elemento;
    }
 else{
     /* Si la lista no está vacía, hace que el apuntador "siguiente" del nuevo elemento apunte al primer elemento de la lista*/
     if (*lista != NULL)
         nuevo_elemento->siguiente = *lista;
     /* Hace que la lista apunte hacia el nuevo elemento para que sea el primer nodo de la lista*/
     *lista = nuevo_elemento;
    }
}
/*Funcion de busqueda solo de uso para clases tienen tablas predefinidas, regresa la clase a la que pertenece el elemento buscado*/
int buscar(int tabla, char palabra[10]){
	int i;
	if(tabla == 0){
		for (i = 0; i < 20; i=i+1){
			if(strcmp(pr[i].palabra,palabra)==0){return i;}
		}
	}
	if(tabla == 2){
		for (i = 0; i < 5; i=i+1){
			if(strcmp(tde[i].palabra,palabra)==0){return i;}
		}
	}
	if(tabla == 3){
		for (i = 0; i < 11; i=i+1){
			if(strcmp(fe[i].palabra,palabra)==0){return i;}
		}
	}
	if(tabla == 4){
		for (i = 0; i < 6; i=i+1){
			if(strcmp(pe[i].palabra,palabra)==0){return i;}
		}
	}
	if(tabla == 6){
		for (i = 0; i < 6; i=i+1){
			if(strcmp(or[i].palabra,palabra)==0){return i;}
		}
	}
	if(tabla == 11){
		if(strcmp(oa,palabra)==0){return i;}
	}
}
/*Funcion para desplegar tablas de usos multiples, se usa para tabla de identificadores, cadenas y tokens*/
void generar_tabla(elemento element,elemento element1){
	if (element == NULL)
 		fprintf(archSal,"La lista está vacia\n");
	else{
    	while (element != NULL){
            fprintf(archSal,"    %s        %s\n",element1->dato, element->dato);
            element = element->siguiente;
            element1 = element1->siguiente;
        }
	}
}
/*Funcion para guardar tokens*/
void generar_agregar_token(char cclase[3], char valor[10]){
	insertar(&lista_clases, NULL,cclase);
	insertar(&lista_valor, NULL,valor);
}
/*-------------------------------------------------/Funciones----------------------------------------------------------------*/
/*--------------------------------------------Programa principal-------------------------------------------------------------*/
main(int argc, char *argv[])
{
	/*Carga tablas estaticas*/
	tablas();
	/*se abre el archivo en modo lectura y se carga en yyin*/
	/*yyin es la variable de entrada para el analizador lexico*/
	yyin = fopen(argv[1],"r");
	/*se abre el archivo salida en modo escritura y se guarda en archSal*/
	archSal = fopen("salida.txt","w");
	/*Se ejecuta el analizador*/
	printf("\n\n****************Se descartaron comentarios****************");
	printf("\n****************A continuacion se muestran los errores lexicos****************");
	/*Se analizan todos los componentes hasta que se llega al fin del programa cargado*/
	while(strcmp(cposicion,"87")!=0){
		clase = yylex();
		sprintf(cclase, "%d", clase);
		/*Depende de la clase es la manera en que se guardan los tokens*/
		if(clase == 1){
			sprintf(ccontador_p_ident, "%d", contador_p_ident);
			insertar(&lista_ident, NULL,yytext);
			insertar(&lista_posident, NULL,ccontador_p_ident);
			generar_agregar_token(cclase, ccontador_p_ident);
			contador_p_ident++;
		}
		if(clase == 10){
			sprintf(ccontador_p_ca, "%d", contador_p_ca);
			insertar(&lista_ca, NULL,yytext);
			insertar(&lista_posca, NULL,ccontador_p_ca);
			generar_agregar_token(cclase, ccontador_p_ca);
			contador_p_ca++;
		}
		if(clase == 5 || clase == 7){
			generar_agregar_token(cclase, yytext);
		}
		if(clase == 8 || clase == 9){
			generar_agregar_token(cclase, yytext);
		}
		if(clase  == 0 || clase == 2 || clase == 3 || clase == 4 || clase == 6 || clase == 11){
			posicion = buscar(clase, yytext);
			sprintf(cposicion, "%d", posicion);
			if(strcmp(cposicion,"87")!=0){
				generar_agregar_token(cclase,cposicion);
			}
		}
	}
	/*Se desplegan en un archivo las tablas generadas*/
	fprintf(archSal,"---------------------------------TABLA DE SIMBOLOS------------------------------\n\n");
	fprintf(archSal,"POSICION     NOMBRE DEL IDENTIFICADOR              TIPO\n\n");
	generar_tabla(lista_ident,lista_posident);
	fprintf(archSal,"\n\n---------------------------------TABLA DE CADENAS------------------------------\n\n");
	fprintf(archSal,"POSICION     CADENA\n\n");
	generar_tabla(lista_ca,lista_posca);
	fprintf(archSal,"\n\n---------------------------------TOKENS------------------------------\n\n");
	fprintf(archSal,"CLASE     POSICION\n\n");
	generar_tabla(lista_valor, lista_clases);
	printf("Se genero el archivo con las tablas exitosamente\n");
	/*Se cierra el archivo*/
	fclose(archSal);
}
/*--------------------------------------------/Programa principal-------------------------------------------------------------*/
