// Script para generar embeddings de memorias faltantes
// Ejecutar con: deno run --allow-net generate_embeddings.ts

const SUPABASE_URL = "https://prohlxpjcaossoqsutzd.supabase.co";
const ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InByb2hseHBqY2Fvc3NvcXN1dHpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwNTA2MjYsImV4cCI6MjA3MTYyNjYyNn0.mHNro_os82-EKPW7lwn3dIr9EsLQNLqjI5LzLmI7WGw";

const MEMORY_IDS = [1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 14, 15, 16, 17, 18, 24];

async function generateEmbedding(id: number): Promise<{ ok: boolean; error?: string }> {
    try {
        const response = await fetch(`${SUPABASE_URL}/functions/v1/embed`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${ANON_KEY}`,
            },
            body: JSON.stringify({
                id,
                schema: "public",
                table: "memories",
                contentFunction: "embedding_input_memories_lite",
                embeddingColumn: "embedding",
            }),
        });

        const result = await response.json();
        return result;
    } catch (error) {
        return { ok: false, error: String(error) };
    }
}

async function main() {
    console.log(`Generando embeddings para ${MEMORY_IDS.length} memorias...\n`);

    for (const id of MEMORY_IDS) {
        process.stdout.write(`Memoria ${id}... `);
        const result = await generateEmbedding(id);

        if (result.ok) {
            console.log("✅");
        } else {
            console.log(`❌ Error: ${result.error}`);
        }

        // Pequeña pausa para no saturar la API
        await new Promise(resolve => setTimeout(resolve, 500));
    }

    console.log("\n¡Proceso completado!");
}

main();
