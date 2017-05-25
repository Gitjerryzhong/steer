package cn.edu.bnuz.steer


import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.web.ControllerUnitTestMixin} for usage instructions
 */
@TestFor(SupervisorSettingInterceptor)
class SupervisorSettingInterceptorSpec extends Specification {

    def setup() {
    }

    def cleanup() {

    }

    void "Test supervisorSetting interceptor matching"() {
        when:"A request matches the interceptor"
            withRequest(controller:"observerSetting")

        then:"The interceptor does match"
            interceptor.doesMatch()
    }
}
