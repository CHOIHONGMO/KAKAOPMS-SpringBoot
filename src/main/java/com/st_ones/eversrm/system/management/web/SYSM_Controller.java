package com.st_ones.eversrm.system.management.web;

import com.st_ones.common.serverpush.reverseajax.EverAlarm;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.sql.DataSource;
import java.io.RandomAccessFile;
import java.lang.management.*;
import java.sql.DatabaseMetaData;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/eversrm/system/management")
public class SYSM_Controller extends BaseController {

    @Autowired
    private DataSource dataSource;


    @RequestMapping("/SYSM_010/view")
    public String sysm010View() {
        return "/eversrm/system/management/SYSM_010";
    }

    @RequestMapping("/SYSM_010/alarmNotice")
    public void alarmNotice(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formDataObject = req.getFormData();

        new EverAlarm().pushData("letterAlarm", "ALL", null, formDataObject.get("NOTICE_TEXT"), null);
    }

    @RequestMapping("/watcher/view")
    public String watcher(EverHttpRequest req) throws Exception {

        String path = "";
        if(PropertiesManager.getBoolean("eversrm.system.localserver")) {
            path = "C:/Logs/KAKAOPMS/KAKAOPMS-web.log";
        } else {
            if(PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
                path = "C:/Logs/KAKAOPMS/KAKAOPMS-Demo/KAKAOPMS-web.log";
            } else {
                path = "C:/Logs/KAKAOPMS/KAKAOPMS-Prod/KAKAOPMS-web.log";
            }
        }

        RandomAccessFile randomAccessFile = new RandomAccessFile(path, "r");
        long totalLength = randomAccessFile.length();
        long startPoint = totalLength - 300000 > 0 ? totalLength - 300000 : 0;
        randomAccessFile.seek(startPoint);

        long endPoint;
        String str;
        StringBuilder sb = new StringBuilder();
        while ((str = randomAccessFile.readLine()) != null) {
            sb.append("").append(new String(str.getBytes("iso-8859-1"), "utf-8").replaceAll("<", "&lt;")).append("\n");
            endPoint = randomAccessFile.getFilePointer();
            randomAccessFile.seek(endPoint);
        }

        randomAccessFile.close();

        String resultString = sb.toString();
        resultString = resultString.replaceAll(" ", "&nbsp;");
        resultString = resultString.replaceAll("\t", "&nbsp;&nbsp;&nbsp;");
        resultString = resultString.replaceAll("INFO", "<span style='color:#0a8eeb;'>INFO</span>");
        resultString = resultString.replaceAll("WARN", "<span style='color:orange;'>WARN</span>");
        resultString = resultString.replaceAll("ERROR", "<span style='color:red;'>ERROR</span>");
        req.setAttribute("logString", resultString);

        DatabaseMetaData metaData = dataSource.getConnection().getMetaData();

        List<MemoryPoolMXBean> memoryPoolMXBeans = ManagementFactory.getMemoryPoolMXBeans();
        Iterator<MemoryPoolMXBean> iterator = memoryPoolMXBeans.iterator();
        while(iterator.hasNext()) {
            MemoryPoolMXBean next = iterator.next();
            getLog().info("{} : {} : {} : {} : {} : {} : {}", next.getName(), next.getType(), next.getUsage().getMax(), next.getUsage().getUsed(), next.getCollectionUsage(), next.getPeakUsage());
        }

        getLog().info("-----------------------------------------------------------------------------------------------");

        ClassLoadingMXBean classLoadingMXBean = ManagementFactory.getClassLoadingMXBean();
        getLog().info("{} : {} : {} : {}", classLoadingMXBean.getTotalLoadedClassCount(), classLoadingMXBean.getLoadedClassCount(), classLoadingMXBean.getUnloadedClassCount());

        getLog().info("-----------------------------------------------------------------------------------------------");

        ThreadMXBean threadMXBean = ManagementFactory.getThreadMXBean();
        getLog().info("ThreadCount: {}", threadMXBean.getThreadCount());

        getLog().info("-----------------------------------------------------------------------------------------------");

        RuntimeMXBean runtimeMXBean = ManagementFactory.getRuntimeMXBean();
        getLog().info("{} : {} : {} : {} : {}", runtimeMXBean.getStartTime(), runtimeMXBean.getUptime(), runtimeMXBean.getLibraryPath(), runtimeMXBean.getSpecName(), runtimeMXBean.getName());

        getLog().info("-----------------------------------------------------------------------------------------------");

        OperatingSystemMXBean operatingSystemMXBean = ManagementFactory.getOperatingSystemMXBean();
        getLog().info("{} : {} : {} : {} : {}", operatingSystemMXBean.getName(), operatingSystemMXBean.getArch(), operatingSystemMXBean.getAvailableProcessors(), operatingSystemMXBean.getSystemLoadAverage());

        getLog().info("-----------------------------------------------------------------------------------------------");

        MemoryMXBean memoryMXBean = ManagementFactory.getMemoryMXBean();
        getLog().info("{} : {} : {}", memoryMXBean.getHeapMemoryUsage(), memoryMXBean.getNonHeapMemoryUsage(), memoryMXBean.getObjectPendingFinalizationCount());

        return "/eversrm/system/management/watcher";
    }

    /**
     * 사용자의 동작이 없으면 1분 후 Ajax 통신 시 NTLM 이 재인증되는 것 같음.
     * 그래서 55초마다 이렇게 내부적으로는 아무것도 안하는 컨트롤러를 강제 호출시킴.
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping("/SYSM_010/keepConnection")
    public void keepConnection(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        // do nothing.
    }

    @RequestMapping("/SYSM_010/getSystemInfo")
    public void getSystemInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

//        JSONObject systemJsonObj = new JSONObject();
//
//        JSONObject memoryJsonObj = new JSONObject();
//        MemoryMXBean memoryMXBean = ManagementFactory.getMemoryMXBean();
//        memoryJsonObj.put("heapMemoryUsage", memoryMXBean.getHeapMemoryUsage());
//        memoryJsonObj.put("nonHeapMemoryUsage", memoryMXBean.getNonHeapMemoryUsage());
//        systemJsonObj.put("memory",  memoryJsonObj);
//
//        CompilationMXBean compilationMXBean = ManagementFactory.getCompilationMXBean();
//        compilationMXBean.getName();
//        compilationMXBean.getTotalCompilationTime();
//
//        JSONObject operatingSystemJsonObj = new JSONObject();
//        OperatingSystemMXBean operatingSystemMXBean = ManagementFactory.getOperatingSystemMXBean();
//        operatingSystemJsonObj.put("name", operatingSystemMXBean.getName());
//        operatingSystemJsonObj.put("arch", operatingSystemMXBean.getArch());
//        operatingSystemJsonObj.put("version", operatingSystemMXBean.getVersion());
//        operatingSystemJsonObj.put("availableProcessors", operatingSystemMXBean.getAvailableProcessors());
//        operatingSystemJsonObj.put("systemLoadAverage", operatingSystemMXBean.getSystemLoadAverage());
//        systemJsonObj.put("operatingSystem",  operatingSystemJsonObj);
//
//        JSONObject classLoading = new JSONObject();
//        ClassLoadingMXBean classLoadingMXBean = ManagementFactory.getClassLoadingMXBean();
//        classLoading.put("totalLoadedClassCount", classLoadingMXBean.getTotalLoadedClassCount());
//        classLoading.put("loadedClassCount", classLoadingMXBean.getLoadedClassCount());
//        classLoading.put("unloadedClassCount", classLoadingMXBean.getUnloadedClassCount());
//
////        HotSpotDiagnosticMXBean diagnosticMXBean = ManagementFactory.getDiagnosticMXBean();
//
//        MBeanServer platformMBeanServer = java.lang.management.ManagementFactory.getPlatformMBeanServer();
//
////        List<GarbageCollectorMXBean> garbageCollectorMXBeans = ManagementFactory.getGarbageCollectorMXBeans();
//
//        JSONObject hotspotClassLoading = new JSONObject();
//        HotspotClassLoadingMBean hotspotClassLoadingMBean = ManagementFactory.getHotspotClassLoadingMBean();
//        hotspotClassLoading.put("classInitializationTime", hotspotClassLoadingMBean.getClassInitializationTime());
//        hotspotClassLoading.put("classLoadingTime", hotspotClassLoadingMBean.getClassLoadingTime());
//        hotspotClassLoading.put("initializedClassCount", hotspotClassLoadingMBean.getInitializedClassCount());
//        hotspotClassLoading.put("loadedClassSize", hotspotClassLoadingMBean.getLoadedClassSize());
//        hotspotClassLoading.put("unloadedClassSize", hotspotClassLoadingMBean.getUnloadedClassSize());
//
//        HotspotRuntimeMBean hotspotRuntimeMBean = ManagementFactory.getHotspotRuntimeMBean();
//        hotspotRuntimeMBean.getTotalSafepointTime();
//
//        HotspotThreadMBean hotspotThreadMBean = ManagementFactory.getHotspotThreadMBean();
//        hotspotThreadMBean.getInternalThreadCount();
//
////        HotspotMemoryMBean hotspotMemoryMBean = ManagementFactory.getHotspotMemoryMBean();
//
////        HotspotCompilationMBean hotspotCompilationMBean = ManagementFactory.getHotspotCompilationMBean();
//
//        JSONObject runtimeJsonObj = new JSONObject();
//        RuntimeMXBean runtimeMXBean = ManagementFactory.getRuntimeMXBean();
//        runtimeJsonObj.put("bootClassPath", runtimeMXBean.getBootClassPath());
//        runtimeJsonObj.put("classPath", runtimeMXBean.getClassPath());
//        runtimeJsonObj.put("libraryPath", runtimeMXBean.getLibraryPath());
//        runtimeJsonObj.put("managementSpecVersion", runtimeMXBean.getManagementSpecVersion());
//        runtimeJsonObj.put("name", runtimeMXBean.getName());
//        runtimeJsonObj.put("specName", runtimeMXBean.getSpecName());
//        runtimeJsonObj.put("specVendor", runtimeMXBean.getSpecVendor());
//        runtimeJsonObj.put("specVersion", runtimeMXBean.getSpecVersion());
//        runtimeJsonObj.put("startTime", runtimeMXBean.getStartTime());
//        runtimeJsonObj.put("vmName", runtimeMXBean.getVmName());
//        runtimeJsonObj.put("vmVendor", runtimeMXBean.getVmVendor());
//        runtimeJsonObj.put("vmVersion", runtimeMXBean.getVmVersion());
//        systemJsonObj.put("runtime", runtimeJsonObj);
//
////        List<MemoryManagerMXBean> memoryManagerMXBeans = ManagementFactory.getMemoryManagerMXBeans();
//
////        List<MemoryPoolMXBean> memoryPoolMXBeans = ManagementFactory.getMemoryPoolMXBeans();
//
//        JSONObject threadJsonObj = new JSONObject();
//        ThreadMXBean threadMXBean = ManagementFactory.getThreadMXBean();
//        threadJsonObj.put("currentThreadCpuTime", threadMXBean.getCurrentThreadCpuTime());
//        threadJsonObj.put("daemonThreadCount", threadMXBean.getDaemonThreadCount());
//        threadJsonObj.put("threadCount", threadMXBean.getThreadCount());
//        threadJsonObj.put("peakThreadCount", threadMXBean.getPeakThreadCount());
//        systemJsonObj.put("thread", threadJsonObj);
//
//        resp.setParameter("systemInfo", systemJsonObj.toJSONString());
    }
}
