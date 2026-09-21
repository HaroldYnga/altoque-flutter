from pathlib import Path

import joblib
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline


BASE_DIR = Path(__file__).resolve().parent
DATASET_PATH = BASE_DIR / "dataset_emergencias.csv"
MODEL_PATH = BASE_DIR / "modelo_emergencias.joblib"


def main() -> None:
    if not DATASET_PATH.exists():
        raise FileNotFoundError(
            f"No se encontró el dataset: {DATASET_PATH}"
        )

    data = pd.read_csv(DATASET_PATH)

    required_columns = {"texto", "categoria"}

    if not required_columns.issubset(data.columns):
        raise ValueError(
            "El CSV debe tener las columnas texto y categoria."
        )

    data = data.dropna(subset=["texto", "categoria"])
    data["texto"] = data["texto"].astype(str).str.strip()
    data["categoria"] = data["categoria"].astype(str).str.strip()

    data = data[
        (data["texto"] != "") &
        (data["categoria"] != "")
    ]

    x_train, x_test, y_train, y_test = train_test_split(
        data["texto"],
        data["categoria"],
        test_size=0.25,
        random_state=42,
        stratify=data["categoria"],
    )

    model = Pipeline(
        steps=[
            (
                "vectorizer",
                TfidfVectorizer(
                    lowercase=True,
                    strip_accents="unicode",
                    ngram_range=(1, 2),
                    sublinear_tf=True,
                ),
            ),
            (
                "classifier",
                LogisticRegression(
                    max_iter=2000,
                    class_weight="balanced",
                    random_state=42,
                ),
            ),
        ]
    )

    model.fit(x_train, y_train)

    predictions = model.predict(x_test)
    accuracy = accuracy_score(y_test, predictions)

    print("\n=== RESULTADOS ===")
    print(f"Exactitud: {accuracy:.2%}")

    print("\n=== REPORTE DE CLASIFICACIÓN ===")
    print(
        classification_report(
            y_test,
            predictions,
            zero_division=0,
        )
    )

    print("\n=== MATRIZ DE CONFUSIÓN ===")
    print(confusion_matrix(y_test, predictions))

    joblib.dump(model, MODEL_PATH)

    print(f"\nModelo guardado en:\n{MODEL_PATH}")

    test_phrases = [
        "Acaban de quitarle el celular a una persona",
        "Mi hermano está inconsciente",
        "Sale humo de la casa del vecino",
        "Hay sujetos causando desorden en el parque",
    ]

    print("\n=== PRUEBAS ===")

    probabilities = model.predict_proba(test_phrases)
    categories = model.predict(test_phrases)

    for phrase, category, scores in zip(
        test_phrases,
        categories,
        probabilities,
    ):
        confidence = float(scores.max())

        print(
            f"\nFrase: {phrase}\n"
            f"Categoría: {category}\n"
            f"Confianza: {confidence:.2%}"
        )


if __name__ == "__main__":
    main()