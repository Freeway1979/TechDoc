# 从 source map 还原原始JS代码

package.json:
```json
{
   "restore:main": "node scripts/restore-from-sourcemap.js dist/main.js dist/main.js.map restored/main",
    "restore:bg": "node scripts/restore-from-sourcemap.js dist/bg.js dist/bg.js.map restored/bg"
}
```
scripts/restore-from-sourcemap.js:

```javascript
#!/usr/bin/env node

/**
 * 从 source map 还原原始代码的工具
 * 使用方法:
 *   node scripts/restore-from-sourcemap.js dist/main.js dist/main.js.map output/
 */

const fs = require('fs');
const path = require('path');
const { SourceMapConsumer } = require('source-map');

async function restoreFromSourceMap(bundleFile, sourceMapFile, outputDir) {
    console.log('Reading source map...');
    const sourceMapContent = fs.readFileSync(sourceMapFile, 'utf8');
    const sourceMap = JSON.parse(sourceMapContent);
    
    console.log('Reading bundle file...');
    const bundleContent = fs.readFileSync(bundleFile, 'utf8');
    
    console.log('Processing source map...');
    const consumer = await new SourceMapConsumer(sourceMap);
    
    // 确保输出目录存在
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }
    
    // 获取所有源文件
    const sources = sourceMap.sources || [];
    const sourcesContent = sourceMap.sourcesContent || [];
    
    console.log(`Found ${sources.length} source files`);
    
    // 还原每个源文件
    const restoredFiles = {};
    
    for (let i = 0; i < sources.length; i++) {
        const sourcePath = sources[i];
        const sourceContent = sourcesContent[i];
        
        if (!sourceContent) {
            console.warn(`No content for source: ${sourcePath}`);
            continue;
        }
        
        // 清理路径（移除 webpack:// 前缀等）
        let cleanPath = sourcePath;
        if (cleanPath.startsWith('webpack:///')) {
            cleanPath = cleanPath.replace('webpack:///', '');
        }
        if (cleanPath.startsWith('./')) {
            cleanPath = cleanPath.substring(2);
        }
        
        // 创建输出路径
        const outputPath = path.join(outputDir, cleanPath);
        const outputDirPath = path.dirname(outputPath);
        
        // 确保目录存在
        if (!fs.existsSync(outputDirPath)) {
            fs.mkdirSync(outputDirPath, { recursive: true });
        }
        
        // 写入文件
        fs.writeFileSync(outputPath, sourceContent, 'utf8');
        restoredFiles[cleanPath] = outputPath;
        
        console.log(`✓ Restored: ${cleanPath}`);
    }
    
    // 生成映射信息文件
    const mappingInfo = {
        bundleFile: path.basename(bundleFile),
        sourceMapFile: path.basename(sourceMapFile),
        totalSources: sources.length,
        restoredFiles: Object.keys(restoredFiles),
        timestamp: new Date().toISOString()
    };
    
    fs.writeFileSync(
        path.join(outputDir, 'restore-info.json'),
        JSON.stringify(mappingInfo, null, 2),
        'utf8'
    );
    
    console.log(`\n✓ Restored ${sources.length} files to ${outputDir}`);
    console.log(`✓ Mapping info saved to ${path.join(outputDir, 'restore-info.json')}`);
    
    consumer.destroy();
}

// 命令行参数处理
const args = process.argv.slice(2);

if (args.length < 2) {
    console.log('Usage: node scripts/restore-from-sourcemap.js <bundle.js> <bundle.js.map> [output-dir]');
    console.log('\nExample:');
    console.log('  node scripts/restore-from-sourcemap.js dist/main.js dist/main.js.map restored/');
    process.exit(1);
}

const bundleFile = args[0];
const sourceMapFile = args[1];
const outputDir = args[2] || 'restored';

if (!fs.existsSync(bundleFile)) {
    console.error(`Error: Bundle file not found: ${bundleFile}`);
    process.exit(1);
}

if (!fs.existsSync(sourceMapFile)) {
    console.error(`Error: Source map file not found: ${sourceMapFile}`);
    process.exit(1);
}

restoreFromSourceMap(bundleFile, sourceMapFile, outputDir)
    .then(() => {
        console.log('\n✓ Done!');
    })
    .catch((error) => {
        console.error('Error:', error);
        process.exit(1);
    });

```